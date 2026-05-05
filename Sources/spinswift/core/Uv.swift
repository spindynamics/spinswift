import Foundation
import Logging
import PythonKit

/// Namespace for `uv`-managed Python environment configuration.
///
/// Locates the project's `uv`-managed Python installation and configures
/// `PYTHON_LIBRARY` and `sys.path` so that `PythonKit` interoperates with
/// the project's virtual environment (`.venv`).
public enum PythonEnvironment {

  // MARK: - Public API

  /// Configures PythonKit to use the project's `uv`-managed Python and `.venv`.
  public static func configure() {
    guard let root = findProjectRoot() else {
      logger.error("Could not locate project root.")
      return
    }
    guard let version = readPythonVersion(at: root), isValidVersion(version) else {
      logger.error("Missing or invalid Python version in .python-version.")
      return
    }
    guard let env = discover(version: version) else {
      logger.error("uv-managed Python \(version) environment not found.")
      return
    }

    setenv("PYTHON_LIBRARY", env.libraryPath, 1)

    let sys = Python.import("sys")
    sys.path.clear()
    env.sysPath.forEach { sys.path.append($0) }
    appendVenvSitePackages(root: root, version: version, to: sys)
  }

  // MARK: - Types

  /// Resolved environment details consumed during configuration.
  struct Env {
    let libraryPath: String
    let sysPath: [String]
  }

  // MARK: - Private

  private static let logger = Logger(label: "spinswift.PythonEnvironment")

  private static let uvRoot: URL =
    FileManager.default
    .homeDirectoryForCurrentUser
    .appendingPathComponent(".local/share/uv/python")

  /// Python script that prints the shared library path followed by `sys.path`.
  private static let probeScript = """
    import sys, sysconfig, os
    print(os.path.join(
      sysconfig.get_config_var('LIBDIR'),
      sysconfig.get_config_var('LDLIBRARY')))
    print('\\n'.join(sys.path))
    """

  private static let versionRegex: NSRegularExpression = {
    // Safe: pattern is a compile-time constant.
    return try! NSRegularExpression(pattern: #"^[0-9]+(\.[0-9]+){0,2}$"#)
  }()

  /// Validates that `s` is a safe, semver-like Python version (e.g. `3.11`, `3.11.15`).
  private static func isValidVersion(_ s: String) -> Bool {
    let range = NSRange(s.startIndex..., in: s)
    return versionRegex.firstMatch(in: s, options: [], range: range) != nil
  }

  /// Walks parents of the current directory to locate the project root.
  ///
  /// Preference order, collected during traversal:
  /// 1. A directory containing both `.python-version` and `.venv`.
  /// 2. A directory containing `.python-version`.
  /// This avoids selecting nested Swift packages (e.g. `Examples/`) that
  /// may ship their own `.python-version` but no Python environment.
  private static func findProjectRoot(maxDepth: Int = 32) -> URL? {
    let fm = FileManager.default
    var current = URL(fileURLWithPath: fm.currentDirectoryPath)
    var versionOnlyFallback: URL?

    for _ in 0..<maxDepth {
      let hasVersion = fm.fileExists(
        atPath: current.appendingPathComponent(".python-version").path)
      let hasVenv = fm.fileExists(
        atPath: current.appendingPathComponent(".venv").path)

      if hasVersion && hasVenv { return current }
      if hasVersion && versionOnlyFallback == nil { versionOnlyFallback = current }

      let parent = current.deletingLastPathComponent()
      if parent.path == current.path { break }
      current = parent
    }
    return versionOnlyFallback
  }

  /// Reads the trimmed contents of `.python-version` at the project root.
  private static func readPythonVersion(at root: URL) -> String? {
    let file = root.appendingPathComponent(".python-version")
    guard let raw = try? String(contentsOf: file, encoding: .utf8) else {
      logger.error("Could not read .python-version at \(file.path)")
      return nil
    }
    return raw.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Resolves the shared library path and `sys.path` for the requested Python version.
  private static func discover(version: String) -> Env? {
    guard let versionDir = findVersionDirectory(version: version) else {
      logger.error("No uv-managed directory matches cpython-\(version).")
      return nil
    }
    let exec = versionDir.appendingPathComponent("bin/python3")
    guard FileManager.default.fileExists(atPath: exec.path) else {
      logger.error("Python executable not found at \(exec.path)")
      return nil
    }
    return queryPython(executable: exec)
  }

  /// Finds the first `cpython-<version>*` directory under the uv root.
  private static func findVersionDirectory(version: String) -> URL? {
    let contents =
      (try? FileManager.default.contentsOfDirectory(
        at: uvRoot, includingPropertiesForKeys: nil)) ?? []
    return contents.first { $0.lastPathComponent.contains("cpython-\(version)") }
  }

  /// Invokes the Python executable with `probeScript` and parses its output.
  private static func queryPython(executable: URL) -> Env? {
    let process = Process()
    let pipe = Pipe()
    process.executableURL = executable
    process.arguments = ["-c", probeScript]
    process.standardOutput = pipe

    do {
      try process.run()
    } catch {
      logger.error("Failed to run \(executable.path): \(error.localizedDescription)")
      return nil
    }
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else {
      logger.error("Could not decode Python probe output.")
      return nil
    }

    let lines =
      output
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map(String.init)
    guard let libraryPath = lines.first, !libraryPath.isEmpty else {
      logger.error("Could not determine Python library path.")
      return nil
    }
    let sysPath = lines.dropFirst().filter { !$0.isEmpty }
    return Env(libraryPath: libraryPath, sysPath: sysPath)
  }

  /// Appends the project's `.venv` site-packages directory to `sys.path` when present.
  private static func appendVenvSitePackages(
    root: URL, version: String, to sys: PythonObject
  ) {
    let site =
      root
      .appendingPathComponent(".venv")
      .appendingPathComponent("lib")
      .appendingPathComponent("python\(version)")
      .appendingPathComponent("site-packages")
      .path
    guard FileManager.default.fileExists(atPath: site) else {
      logger.warning("site-packages not found at \(site)")
      return
    }
    let alreadyPresent = Bool(sys.path.__contains__(site)) ?? false
    if !alreadyPresent { sys.path.append(site) }
  }
}
