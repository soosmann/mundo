# MiMundo

This project is the implementation of our Software-Engineering Project app MiMundo.
MiMundo allows the it's users to document their trips with a MiMundo account.
To document a trip, users create posts that will be shared with all users of the app.
The app implements a follower system that allows users to follow their friends and view their posts on a for-you-page.
All posts are associated with a place (e. g. a vacation destination). 
By doing this, other uses can also search for this place and have a look, what things can be done there.

## Install MiMundo on a Device

To run the app, this repository must be downloaded locally (Git, Zip-File).

### Android Emulator

To run this project on an Android Emulator, start an Android Emulator.
Android Emulators can be created in [Android Studio](https://developer.android.com/studio?hl=de).

Firsly, upgrade Flutter to the latest version:
```
flutter upgrade
```
Clear the Flutter Cache with:
```
flutter clean
```
In the root directory of this project execute this to download Flutter dependencies of the project:
```
flutter pub get
```
After having installed dependencies and having started the emulator, use this command to start the app:
```
flutter run
```
If necessary, follow the instructions in the terminal output.

### iOS Emulator

To run this project on an iOS Emulator, start an iOS Emulator.
This typically only works on Apple devices. In Xcode, iOS emulators can be configured.

Dependencies for the iOS app are fetched via CocoaPods. Make sure you have at least CocoaPods 1.13.0 installed (check with ``pod --version``). If not, try:
```
sudo gem update cocoapods
```
If this does not work, try:
```
brew install cocoapods
```
Clear the Flutter Cache with:
```
flutter clean
```
In the root directory of this project execute this to download Flutter dependencies of the project:
```
flutter pub get
```
Install the iOS dependencies with this command:
```
pod install
```
After having installed dependencies and having started the emulator, use this command to start the app:
```
flutter run
```
If necessary, follow the instructions in the terminal output.

### Real Android Device

Firsly, upgrade Flutter to the latest version:
```
flutter upgrade
```
In the terminal, move into the Android directory of this Flutter project:
```
cd android
```
Clear the Flutter Cache with:
```
flutter clean
```
To build an executable apk that can be used to install the app on a real device, execute:
```
flutter build apk --release
```
If the .apk filecould be built correctly, you can find it in the build folder: ``build/app/outputs/``. Put this file on your android phone and execute it to install MiMundo.

### Real iOS Device

Connect an iPhone to your computer

Run this project in Xcode by selecting  ``ios/Runner.xcworkspace`` as directory to open in Xcode. 
In Xcode in the general project settings, set your Apple Developer Account as "Team"-value.

On your iPhone, in Settings, go to ``General/Device Management``and add a Developer Account if necessary. 
Select to trust your developer account to be able to execute the app.

At the top in Xcode, select your attached Apple device and click on the run button. 
The app will be built and installed on your Apple device.
Lowest possible iOS version is iOS 17.
