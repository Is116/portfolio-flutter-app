# NFC Business Card - Flutter App 📱

A beautiful Flutter app to share your portfolio/contact information via NFC-enabled business cards. Write your details to NFC tags and share them by tapping phones together!

## ✨ Features

- 📝 **Write to NFC Tags** - Store your complete portfolio on NFC tags
- 👁️ **Read NFC Tags** - Read contact info from other NFC tags
- 📇 **vCard Format** - Compatible with phone contacts
- 🎨 **Beautiful UI** - Modern dark theme design
- 📱 **QR Code** - Alternative sharing method
- 🔗 **Direct Links** - Opens portfolio website on tap
- 💼 **Complete Profile** - Name, title, email, phone, social links
- 🌐 **No Internet Required** - Works offline after setup

## 📱 Screenshots

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Home Screen   │  │   Write NFC     │  │   Read NFC      │
│                 │  │                 │  │                 │
│  Profile Card   │  │  Instructions   │  │  Scan Tag       │
│  NFC Status     │  │  Preview Data   │  │  View Results   │
│  Action Buttons │  │  Start Writing  │  │  Open Website   │
│  Contact Info   │  │                 │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode
- NFC-enabled phone for testing

### Installation

1. **Clone or extract this folder**

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure your portfolio data**

Edit `lib/models/portfolio_data.dart`:

```dart
static const PortfolioData defaultData = PortfolioData(
  name: 'Your Name',              // ← Change this
  title: 'Full Stack Developer',  // ← Change this
  email: 'your@email.com',        // ← Change this
  phone: '+1 234 567 8900',       // ← Change this
  website: 'https://yoursite.com', // ← Change this
  linkedin: 'https://linkedin.com/in/you',
  github: 'https://github.com/you',
  twitter: 'https://twitter.com/you',
  bio: 'Your bio here...',
  company: 'Your Company',
  location: 'Your Location',
);
```

4. **Run on device**

```bash
# Android
flutter run

# iOS
flutter run
```

## 🛠️ How to Use

### Writing to NFC Tags

1. Open the app
2. Tap "Write to NFC Tag"
3. Follow the instructions
4. Hold phone near NFC tag until complete
5. Success! Your tag is ready to share

### Reading NFC Tags

1. Open the app
2. Tap "Read NFC Tag"
3. Hold phone near any NFC tag
4. View the contact information
5. Tap to open website or save contact

### Sharing Without NFC

1. Tap "Preview Card Data"
2. Show QR code to others
3. Or share text via messaging apps

## 📋 What Gets Written to NFC Tag

When you write to an NFC tag, it contains:

1. **Website URL** - Opens directly when tapped
2. **vCard Data** - Complete contact information
3. **Plain Text** - Readable backup

### vCard Format Includes:
- Full Name
- Job Title
- Company
- Email Address
- Phone Number
- Website URL
- LinkedIn Profile
- GitHub Profile
- Twitter Profile
- Location
- Bio/Description

## 🔧 Configuration

### Android Setup

The app is already configured, but if you need to modify:

**android/app/src/main/AndroidManifest.xml** - Already includes:
- NFC permissions
- NFC intent filters
- Internet permission

### iOS Setup

**ios/Runner/Info.plist** - Already includes:
- NFC usage description
- NDEF format support
- URL scheme support

**Additional iOS Requirements:**
1. Add NFC capability in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select Runner target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "Near Field Communication Tag Reading"

2. Create `ios/Runner/Runner.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.nfc.readersession.formats</key>
	<array>
		<string>NDEF</string>
		<string>TAG</string>
	</array>
</dict>
</plist>
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  nfc_manager: ^3.3.0        # NFC functionality
  google_fonts: ^6.1.0        # Beautiful fonts
  url_launcher: ^6.2.2        # Open links
  share_plus: ^7.2.1          # Share content
  qr_flutter: ^4.1.0          # QR code generation
```

## 🎨 Customization

### Change Theme Colors

Edit `lib/main.dart`:

```dart
primaryColor: const Color(0xFF0EA5E9),  // Your brand color
```

### Modify UI Components

All screens are in `lib/screens/`:
- `home_screen.dart` - Main screen
- `write_nfc_screen.dart` - Write functionality
- `read_nfc_screen.dart` - Read functionality
- `preview_screen.dart` - Preview and QR code

### Add More Fields

1. Edit `lib/models/portfolio_data.dart`
2. Add new fields to the model
3. Update `toVCard()` and `toPlainText()` methods
4. Update UI screens to display new fields

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── portfolio_data.dart     # Data model
├── services/
│   └── nfc_service.dart        # NFC read/write logic
└── screens/
    ├── home_screen.dart        # Main screen
    ├── write_nfc_screen.dart   # Write to NFC
    ├── read_nfc_screen.dart    # Read from NFC
    └── preview_screen.dart     # Preview & QR code
```

## 📱 Supported Devices

### Android
- Android 4.4 (KitKat) or higher
- Device must have NFC hardware
- NFC must be enabled in settings

### iOS
- iPhone 7 or newer
- iOS 13 or higher
- NFC is always on (no setting needed)

## 🐛 Troubleshooting

### NFC Not Working on Android

1. Check if NFC is enabled:
   - Settings → Connected devices → Connection preferences → NFC
2. Ensure app has permissions
3. Try holding phone closer to tag

### NFC Not Working on iOS

1. Ensure device supports NFC (iPhone 7+)
2. Check entitlements are properly set
3. Make sure tag is NDEF compatible
4. Hold top of phone near tag

### Tag Write Fails

1. Ensure tag is writable (not locked)
2. Use NDEF-compatible tags
3. Keep phone steady during write
4. Try different tag brands

### App Crashes

1. Update Flutter: `flutter upgrade`
2. Clear build: `flutter clean`
3. Reinstall dependencies: `flutter pub get`

## 🛒 Recommended NFC Tags

For best results, use:
- **NTAG213** - 144 bytes (good for basic info)
- **NTAG215** - 504 bytes (recommended)
- **NTAG216** - 888 bytes (best for full profile)

Available on Amazon, eBay, or NFC tag suppliers.

## 🚀 Building for Production

### Android (APK)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (App Store)

```bash
flutter build ios --release
```

Then archive in Xcode.

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Share improvements

## 💡 Use Cases

- **Networking Events** - Share contact instantly
- **Business Cards** - Digital alternative
- **Conferences** - Easy info exchange
- **Portfolio Sharing** - Share your work
- **Team Building** - Quick introductions
- **Trade Shows** - Professional presence

## 🎯 Tips for Best Results

1. **Keep Tags Clean** - Fingerprints affect scanning
2. **Proper Positioning** - Center phone over tag
3. **Steady Hold** - Don't move during write/read
4. **Quality Tags** - Invest in good NFC tags
5. **Test First** - Always test before distributing

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review Flutter NFC Manager docs
3. Open an issue on GitHub

## 🎉 Ready to Go!

Your NFC business card app is ready! Just:
1. Update your info in `portfolio_data.dart`
2. Run the app
3. Write to NFC tags
4. Start sharing!

---

**Made with ❤️ using Flutter**

Happy networking! 📱✨
