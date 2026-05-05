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

* Run the tests (assuming `uv` is installed with latest 3.11 python managed library)
```bash
source .venv/bin/activate
uv sync
PYTHON_VERSION=3.11 PYTHON_LIBRARY=~/.local/share/uv/python/cpython-3.11.15-linux-x86_64-gnu/lib/libpython3.11.so swift test
```

* Build the documentation
```swift
swift package generate-documentation
```

* Preview the documentation
```swift
swift package --disable-sandbox preview-documentation --target spinswift
```

* Run the main programs
```swift
cd Examples
swift run
```
