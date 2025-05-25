# spinswift

No need to install any local swift compiler. Simply install podman/docker and either cp .bash_aliases in your $HOME or prepare your own container as
```bash
cd Docker && podman build -t swift-user . && podman run -it --rm --name swift-user swift-user
```

* Run the tests
```swift
swift test
```

* Build the sources
```swift
swift build
```

* Run the main program
```swift
swift run
```

* Build the documentation
```swift
swift package generate-documentation
```

* Preview the documentation
```swift
swift package --disable-sandbox preview-documentation --target spinswift
```
