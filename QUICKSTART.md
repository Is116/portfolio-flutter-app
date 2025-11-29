# 🚀 Quick Setup Guide

## Get Your NFC Business Card App Running in 5 Minutes!

### Step 1: Install Flutter (if not already installed)

**Windows:**
```bash
# Download Flutter SDK from flutter.dev
# Extract to C:\flutter
# Add to PATH: C:\flutter\bin
```

**Mac:**
```bash
# Install using Homebrew
brew install flutter

# Or download from flutter.dev
```

**Linux:**
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

Verify installation:
```bash
flutter doctor
```

### Step 2: Setup Your IDE

**VS Code:**
```bash
# Install Flutter extension
code --install-extension Dart-Code.flutter
```

**Android Studio:**
- Install Flutter plugin
- Install Dart plugin

### Step 3: Get Dependencies

```bash
cd nfc-business-card
flutter pub get
```

### Step 4: Customize Your Info

Open `lib/models/portfolio_data.dart` and update:

```dart
static const PortfolioData defaultData = PortfolioData(
  name: 'John Doe',                          // ← YOUR NAME
  title: 'Full Stack Developer',             // ← YOUR TITLE
  email: 'john@example.com',                 // ← YOUR EMAIL
  phone: '+1 (555) 123-4567',               // ← YOUR PHONE
  website: 'https://johndoe.com',           // ← YOUR WEBSITE
  linkedin: 'https://linkedin.com/in/john',  // ← YOUR LINKEDIN
  github: 'https://github.com/john',         // ← YOUR GITHUB
  twitter: 'https://twitter.com/john',       // ← YOUR TWITTER
  bio: 'Passionate developer...',            // ← YOUR BIO
  company: 'Tech Inc.',                      // ← YOUR COMPANY
  location: 'San Francisco, CA',             // ← YOUR LOCATION
);
```

### Step 5: Connect Device

**Android:**
```bash
# Enable USB debugging on phone
# Settings → About → Tap Build Number 7 times
# Settings → Developer Options → USB Debugging → ON
# Connect via USB
adb devices  # Verify connection
```

**iOS:**
```bash
# Connect iPhone via USB
# Trust computer when prompted
```

### Step 6: Run App

```bash
flutter run
```

That's it! 🎉

## ⚡ Quick Commands

```bash
# Run app
flutter run

# Build APK
flutter build apk

# Build for iOS
flutter build ios

# Clean project
flutter clean

# Update dependencies
flutter pub get

# Check for issues
flutter doctor
```

## 🎯 First Time Using the App

1. **Open the app** on your NFC-enabled phone
2. **Tap "Write to NFC Tag"**
3. **Hold phone near NFC tag** (keep steady)
4. **Wait for success message**
5. **Test by tapping with another phone**

## 📱 Get NFC Tags

Order from:
- **Amazon** - Search "NTAG215 NFC tags"
- **AliExpress** - Cheap bulk options
- **TagsForDroid** - Specialty NFC supplier

**Recommended:** NTAG215 (504 bytes) - $0.30-$1 each

## ⚙️ iOS Additional Setup

After running for the first time:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Runner" target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Near Field Communication Tag Reading"
6. Run again

## 🐛 Common Issues

**"NFC not available"**
- Check device has NFC hardware
- Enable NFC in phone settings (Android)

**"Build failed"**
```bash
flutter clean
flutter pub get
flutter run
```

**"No device connected"**
```bash
flutter devices  # Check connected devices
adb devices      # Android only
```

## 📚 Next Steps

- ✅ Customize your portfolio data
- ✅ Test writing to an NFC tag
- ✅ Test reading the tag with another phone
- ✅ Share your tag with others!
- ✅ Build APK for distribution
- ✅ Publish to Play Store / App Store (optional)

## 💡 Pro Tips

1. **Test thoroughly** before ordering many tags
2. **Use quality tags** (NTAG215 recommended)
3. **Keep a backup tag** with your info
4. **Clean tags** before writing for best results
5. **Position correctly** - Center phone over tag

## 🎨 Want to Customize UI?

All screens are in `lib/screens/`:
- Change colors in `lib/main.dart`
- Modify layouts in screen files
- Add your own logo/images

## 📞 Need Help?

1. Check `README.md` for detailed docs
2. Run `flutter doctor` for diagnostics
3. Review error messages carefully
4. Check Flutter documentation

---

**You're all set! Start sharing your portfolio via NFC! 🚀**
