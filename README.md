# runevm_fl
 RuneVM plugin for Flutter

 Example app is the game 2048 with voice control

## Getting Started

### Add the RuneVM plugin to your pubspec.yaml file

```
dependencies:
  flutter:
    sdk: flutter
  runevm_fl:
    git:
      url: https://github.com/hotg-ai/runevm_fl.git 

```

### Load and run your rune file

Load and run your rune file in three steps:

#### Deploy
```dart
Future<bool> RunevmFl.load(Uint8List runeBytes)
```
#### Read manifest
```dart
Future<dynamic> RunevmFl.manifest
```
#### Run rune with input bytes
```dart
Future<String> RunevmFl.runRune(Uint8List input)
```

#### Implementation

Full implementatoin in [main.dart](lib/main.dart)

```dart

import 'package:runevm_fl/runevm_fl.dart';

class RunMyRune {

  double _input = 0;
  String? _output;

  Future<void> _loadRune() async {
    try {
      //Load Rune from assets into memory;
      ByteData bytes = await rootBundle.load('assets/sine.rune');
      bool loaded =
          await RunevmFl.load(bytes.buffer.asUint8List()) ?? false;
      print("Rune deployed:");
      if (loaded) {
        //Read Manifest with capabilities
        String manifest = (await RunevmFl.manifest).toString();
        print("Manifest loaded: $manifest");
      }
    } on Exception {
      print('Failed to init rune');
    }
    setState(() {
      _loaded = true;
    });
  }

  void _runRune() async {
    try {
      Random rand = Random();
      _input = rand.nextDouble() * 2 * pi;
      //convert input to 4 bytes representing a Float32 (See assets/Runefile)
      Uint8List inputBytes = Uint8List(4)
        ..buffer.asByteData().setFloat32(0, _input, Endian.little);
      //Run rune with the inputBytes
      _output = await RunevmFl.runRune(inputBytes);
      setState(() {});
    } on Exception {
      print('Failed to run rune');
    }
  }

}

```

### Android

No extra config needed

### iOS

If you are creating a new app, first run :
```console
foo@bar:~$ flutter run
```
to generate the podfile.

Minimum iOS version should be at least 12.1 to be compatible with the plugin:

Set this in XCode > Runner > General > Deployment info


Bitcode needs to be disabled either for the runevm_fl target:

XCode > Pods > Targets > runevm_fl > Build Settings > Enable Bitcode > Set to 'No'

or directly in the Podfile:

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    ## Add these 3 lines to your podfile
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
    
  end
end
```

### Run it 

```console
foo@bar:~$ flutter run
```