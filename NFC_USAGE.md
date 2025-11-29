# NFC Mobile-to-Mobile Sharing Guide

## How It Works

This app enables **mobile-to-mobile NFC sharing** of your portfolio URL. When you tap your phone against another NFC-enabled phone, it will automatically open your portfolio website in their browser.

## Features

### 📤 Share Mode
- Tap the **"Share via NFC"** button
- Hold your phone's back against another NFC phone (back-to-back)
- The other phone will receive your portfolio URL
- Their browser will automatically open your portfolio website

### 📥 Receive Mode  
- Tap the **"Receive from NFC"** button
- Hold your phone's back against another NFC phone or tag
- The URL will be read and automatically opened in your browser

## Usage Instructions

### For Sharing (Your Phone → Their Phone):

1. Open the app on your phone
2. Tap **"Share via NFC"**
3. Wait for the "Hold your phone near..." message
4. Place the **back** of your phone against the **back** of their phone
5. Hold steady for 1-2 seconds
6. You'll see "✓ Successfully shared!" when complete
7. Their phone will automatically open your portfolio URL in the browser

### For Receiving (Their Phone → Your Phone):

1. Open the app on your phone
2. Tap **"Receive from NFC"**
3. Wait for the "Hold your phone near..." message  
4. Place the **back** of your phone against the **back** of their NFC phone/tag
5. Hold steady for 1-2 seconds
6. The URL will be detected and opened automatically

## Technical Details

- Uses NDEF (NFC Data Exchange Format) URI records
- Works with all NFC-enabled Android phones (NFC Forum Type 2/4 tags)
- Requires Android 4.4+ (API 19+) with NFC hardware
- iOS devices can read NFC tags but cannot emulate tags for Android phones to read

## Compatibility

✅ **Android to Android**: Full bidirectional sharing  
✅ **Android to NFC Tag**: Can write and read  
⚠️ **Android to iOS**: iOS can only read, not share back  
❌ **iOS to Android**: iOS cannot emulate NFC tags

## Tips for Best Results

1. **Remove phone cases** - Thick cases can interfere with NFC signal
2. **Position correctly** - Place phones back-to-back, not side-by-side
3. **Hold steady** - Keep phones still for 1-2 seconds
4. **Enable NFC** - Make sure NFC is turned on in phone settings
5. **Unlock phones** - Both phones should be unlocked and screen on

## Troubleshooting

**"NFC is not available"**
- Check if your phone has NFC hardware
- Enable NFC in Settings → Connected devices → Connection preferences → NFC

**"Tag is not NDEF compatible"**
- The other device may not support NDEF format
- Try with a different phone or NFC tag

**"Tag is not writable"**
- The NFC tag/phone may be read-only
- Try receiving instead of sharing

**URL doesn't open automatically**
- Check internet connection
- Try manually opening the displayed URL

## Portfolio URL

Current portfolio: `https://isuru-portfolio-ten.vercel.app/`

To change the URL, update the `portfolioUrl` variable in `lib/screens/home_screen.dart`.

---

**Enjoy seamless NFC sharing! 📱✨**
