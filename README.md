# STTLibrary

## Overview
A simple Swift package wrapper for SFSpeechRecognizer. Returns a string.

## Installation
Using Swift Package Manager, in Xcode:

#### File > Swift Packages > Add Package Dependency
https://github.com/iOSDigital/STTLibrary

#### Or manually
Just drop SSTLibrary.swift into your project.

## Usage
Once you have imported the module:

``` import SSTLibrary.swift ```

Create a instance of the Shared Instance:

``` let sstManager = SSTLibrary.shared ```

On say, a button press, start the recognizing process:

```
STT.startRecognizing { (result) in
switch result {
case .success(let string):
// This is your speech to text result!
print(string)

case .failure(let error):
// Something went wrong :(
print("Error: \(error)")
}
}
```
