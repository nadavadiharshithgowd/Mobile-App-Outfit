# Flutter App Setup Guide

## Prerequisites

Before running the Flutter app, make sure you have:

1. **Flutter SDK** installed (3.2.0 or higher)
2. **Android Studio** (for Android development) or **Xcode** (for iOS development)
3. **VS Code** or **Android Studio** with Flutter plugins
4. **Backend server** running on `http://localhost:8000`

## Quick Start

### 1. Check Flutter Installation

```bash
flutter --version
```

You should see Flutter 3.2.0 or higher.

If Flutter is not installed, follow: https://docs.flutter.dev/get-started/install

### 2. Navigate to Flutter App

```bash
cd flutter_app
```

### 3. Install Dependencies

```bash
flutter pub get
```

This installs all packages from `pubspec.yaml`.

### 4. Run the App

**For Android Emulator:**
```bash
flutter run
```

**For Chrome (Web):**
```bash
flutter run -d chrome
```

**For Windows:**
```bash
flutter run -d windows
```

**For specific device:**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Detailed Setup

### Step 1: Install Flutter SDK

#### Windows

1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to PATH: `C:\src\flutter\bin`
4. Run `flutter doctor` to check setup

#### macOS

```bash
# Using Homebrew
brew install flutter

# Or download from: https://docs.flutter.dev/get-started/install/macos
```

#### Linux

```bash
# Download and extract Flutter
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### Step 2: Install Platform-Specific Tools

#### For Android Development

1. **Install Android Studio**: https://developer.android.com/studio
2. **Install Android SDK** (via Android Studio)
3. **Create Android Emulator**:
   - Open Android Studio
   - Tools → Device Manager
   - Create Virtual Device
   - Choose a device (e.g., Pixel 6)
   - Download system image (e.g., Android 13)
   - Finish setup

4. **Accept Android Licenses**:
   ```bash
   flutter doctor --android-licenses
   ```

#### For iOS Development (macOS only)

1. **Install Xcode**: From Mac App Store
2. **Install Xcode Command Line Tools**:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **Install CocoaPods**:
   ```bash
   sudo gem install cocoapods
   ```

4. **Open iOS Simulator**:
   ```bash
   open -a Simulator
   ```

#### For Web Development

Web support is included by default in Flutter 3.x.

#### For Windows Desktop

```bash
flutter config --enable-windows-desktop
```

### Step 3: Verify Setup

```bash
flutter doctor
```

You should see checkmarks (✓) for:
- Flutter SDK
- Android toolchain (if developing for Android)
- Xcode (if on macOS for iOS)
- Chrome (for web)
- VS Code or Android Studio

### Step 4: Configure Backend URL

The Flutter app needs to connect to your backend. Check the configuration:

**File**: `flutter_app/lib/core/constants/api_constants.dart`

Make sure it points to your backend:

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String wsUrl = 'ws://localhost:8000/ws';
}
```

**For Android Emulator**, use:
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
```

**For Physical Device**, use your computer's IP:
```dart
static const String baseUrl = 'http://192.168.1.x:8000/api/v1';
```

### Step 5: Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### Step 6: Run the App

#### Option A: Using Command Line

```bash
# Run on default device
flutter run

# Run on specific device
flutter devices  # List devices
flutter run -d <device-id>

# Run in release mode (faster)
flutter run --release
```

#### Option B: Using VS Code

1. Open `flutter_app` folder in VS Code
2. Press `F5` or click "Run and Debug"
3. Select device from bottom-right corner
4. App will launch automatically

#### Option C: Using Android Studio

1. Open `flutter_app` folder in Android Studio
2. Select device from device dropdown
3. Click Run button (green play icon)

## Project Structure

```
flutter_app/
├── lib/
│   ├── core/              # Core utilities
│   │   ├── constants/     # API URLs, colors, etc.
│   │   ├── network/       # Dio HTTP client
│   │   ├── storage/       # Secure storage
│   │   ├── theme/         # App theme
│   │   ├── utils/         # Helper functions
│   │   └── widgets/       # Reusable widgets
│   ├── di/                # Dependency injection
│   ├── features/          # Feature modules
│   │   ├── auth/         # Authentication
│   │   ├── wardrobe/     # Wardrobe management
│   │   ├── outfit/       # Outfit recommendations
│   │   ├── tryon/        # Virtual try-on
│   │   └── profile/      # User profile
│   ├── router/           # Navigation
│   ├── app.dart          # App widget
│   └── main.dart         # Entry point
├── assets/               # Images, fonts
├── android/             # Android-specific code
├── ios/                 # iOS-specific code
├── web/                 # Web-specific code
├── windows/             # Windows-specific code
└── pubspec.yaml         # Dependencies
```

## Features

The Flutter app includes:

- ✅ **Authentication**: Email/OTP, Google Sign-In
- ✅ **Digital Wardrobe**: Upload, view, manage clothing items
- ✅ **Outfit Recommendations**: AI-powered suggestions
- ✅ **Virtual Try-On**: Try clothes virtually
- ✅ **User Profile**: Manage account settings

## Running on Different Platforms

### Android

```bash
# Start emulator
flutter emulators --launch <emulator-id>

# Or open Android Studio → Device Manager → Start emulator

# Run app
flutter run
```

### iOS (macOS only)

```bash
# Start simulator
open -a Simulator

# Run app
flutter run
```

### Web

```bash
flutter run -d chrome
```

### Windows

```bash
flutter run -d windows
```

### Physical Device

1. **Enable Developer Mode** on your device
2. **Enable USB Debugging** (Android) or **Trust Computer** (iOS)
3. **Connect device** via USB
4. **Run**:
   ```bash
   flutter devices  # Verify device is detected
   flutter run
   ```

## Troubleshooting

### Issue 1: "Flutter not found"

**Solution**: Add Flutter to PATH

**Windows**:
1. Search "Environment Variables"
2. Edit PATH
3. Add `C:\src\flutter\bin`

**macOS/Linux**:
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Issue 2: "No devices found"

**Solution**:
- For Android: Start an emulator
- For iOS: Open Simulator
- For Web: Chrome should be auto-detected
- For physical device: Enable USB debugging

### Issue 3: "Gradle build failed" (Android)

**Solution**:
```bash
cd flutter_app/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue 4: "CocoaPods not installed" (iOS)

**Solution**:
```bash
sudo gem install cocoapods
cd flutter_app/ios
pod install
cd ..
flutter run
```

### Issue 5: "Connection refused" to backend

**Solutions**:

1. **Check backend is running**:
   ```bash
   curl http://localhost:8000/api/v1/
   ```

2. **For Android Emulator**, use `10.0.2.2` instead of `localhost`

3. **For Physical Device**, use your computer's IP address

4. **Update API URL** in `lib/core/constants/api_constants.dart`

### Issue 6: "Pub get failed"

**Solution**:
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Issue 7: Hot reload not working

**Solution**:
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Or stop and run again

## Development Tips

### Hot Reload

While app is running:
- Press `r` for hot reload (fast, preserves state)
- Press `R` for hot restart (slower, resets state)
- Press `q` to quit

### Debug Mode vs Release Mode

**Debug mode** (default):
```bash
flutter run
```
- Slower performance
- Includes debugging tools
- Hot reload enabled

**Release mode**:
```bash
flutter run --release
```
- Optimized performance
- No debugging tools
- Smaller app size

### View Logs

```bash
flutter logs
```

### Clear Build Cache

```bash
flutter clean
flutter pub get
```

### Update Dependencies

```bash
flutter pub upgrade
```

## Building for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)

```bash
flutter build ios --release
```

Then open Xcode to archive and upload to App Store.

### Web

```bash
flutter build web --release
```

Output: `build/web/`

Deploy to any static hosting (Vercel, Netlify, Firebase Hosting).

### Windows

```bash
flutter build windows --release
```

Output: `build/windows/runner/Release/`

## Testing

### Run Tests

```bash
flutter test
```

### Run Specific Test

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter drive --target=test_driver/app.dart
```

## Useful Commands

```bash
# Check Flutter version
flutter --version

# Check for issues
flutter doctor

# List devices
flutter devices

# List emulators
flutter emulators

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
flutter format .

# Run app
flutter run

# Build release
flutter build apk --release
```

## Next Steps

1. ✅ Start backend server
2. ✅ Start Flutter app
3. ✅ Register/login
4. ✅ Upload wardrobe items
5. ✅ Get outfit recommendations
6. ✅ Try virtual try-on

## Resources

- **Flutter Docs**: https://docs.flutter.dev/
- **Flutter Packages**: https://pub.dev/
- **Flutter Community**: https://flutter.dev/community
- **API Documentation**: Check backend API docs

---

**You're all set!** Run `flutter run` and start using your AI outfit stylist app! 🎉📱
