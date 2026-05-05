For more information about the project, see the [AGENTS.md](AGENTS.md) file.

# spinswift

No need to install any local swift compiler. Simply install podman/docker and prepare your own container:
```bash
podman build -t spinswift . && podman run -it --rm -v.:/workdir:z --name spinswift spinswift
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

* Run the programs in the Examples folder
```swift
source .venv/bin/activate
cd Examples
swift run SimpleTest
swift run sLLG
```
