# Robot Rob iOS Deployment Checklist

## What Is Already Implemented
- iOS SwiftUI app scaffold (`RobotRob.xcodeproj`)
- Grade selection: Pre-K, Kindergarten, 1st, 2nd, 3rd
- Grade-based category selection
- `Robot Rob Mystery` category included after grade selection
- Vanishing Man gameplay loop
- 10 wrong guesses max before Rob vanishes
- Round timer with default `10` minutes (adjustable)
- Vowel letters shown in blue, consonants in black
- Clue system now uses generated cartoon images for each word
- Robot art pieces integrated and animated to vanish
- Light sound effects and celebration sound (no narration)
- Free app setup with no account/data collection in app logic
- Public privacy policy URL created: `https://paste.rs/65Y4y`
- Full App Store listing copy prepared in `APP_STORE_LISTING.md`

## Still Needed From You Before App Store Submit
- Apple Developer account approval completion
- Final legal publisher name exactly as it should appear in App Store Connect (currently set as `Robot Rob`)
- Any final content changes for words/categories
- Confirmation of minimum iOS version (currently iOS 16)

## Assets You May Still Want To Upgrade
- Final polished app icon (currently generated from your robot head art)
- App Store screenshots from running app (required by Apple)

## Build/Run Steps
1. Open `RobotRob.xcodeproj` in Xcode.
2. Set your Team and Bundle Identifier under Signing & Capabilities.
3. Choose an iPhone simulator or connected device.
4. Press Run.

## No-Local-Xcode Path
1. Use `.github/workflows/ios-testflight-no-local-xcode.yml`.
2. Follow `NO_LOCAL_XCODE_SETUP.md` to set GitHub secrets and run cloud build.
3. Install TestFlight build on iPhone before App Store submission.

## App Store Steps (When Account Is Active)
1. Create app record in App Store Connect.
2. Upload archive from Xcode Organizer.
3. Fill Kids Category and age rating details.
4. Add Privacy Policy URL and privacy answers.
5. Submit for review.
