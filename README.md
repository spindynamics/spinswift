# spinswift

No need to install a swift compiler. Simply cp .bash_aliases in your $HOME and install podman/docker

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
