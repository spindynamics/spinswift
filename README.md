For more information about the project, see the [AGENTS.md](AGENTS.md) file.

# spinswift

No need to install any local swift compiler. Simply install podman/docker and either cp .bash_aliases in your $HOME or prepare your own container as
```bash
cd Docker && podman build -t swift-user . && podman run -it --rm --name swift-user swift-user
```

* Build the sources
```swift
swift build
```

* Set up the python environment
```bash
uv sync
source .venv/bin/activate
```

* Run the tests
```bash
PYTHON_LOADER_LOGGING=TRUE PYTHON_VERSION=$(cat .python-version) swift test
```

* Build the documentation
```swift
swift package generate-documentation
```

* Preview the documentation
```swift
swift package --disable-sandbox preview-documentation --target spinswift
```

* Run the programs found in the Examples folder 
```swift
source .venv/bin/activate
cd Examples
swift run SimpleTest
swift run sLLG
```
