# No-Local-Xcode Setup (GitHub Actions -> TestFlight)

This setup lets you build and upload Robot Rob to TestFlight without installing Xcode on your Mac.

## What You Need
- Apple Developer Program account (once approved)
- App Store Connect access (Account Holder/Admin/App Manager)
- GitHub repository containing this project
- TestFlight app on iPhone (you already installed it)

## 1. Push This Project To GitHub
Create a GitHub repo, then push this folder including:
- `.github/workflows/ios-testflight-no-local-xcode.yml`
- `project.yml`
- `RobotRobApp/**`

## 2. Create App Store Connect API Key (Web)
In App Store Connect:
1. Go to `Users and Access` -> `Integrations` -> `App Store Connect API`.
2. Create key with at least `App Manager` access.
3. Download the `.p8` file once (Apple only allows one download).
4. Save:
   - `Key ID`
   - `Issuer ID`
   - `.p8` file contents

## 3. Prepare GitHub Secrets
In GitHub repo settings -> `Secrets and variables` -> `Actions`, add:

- `APPLE_TEAM_ID` = your Apple Team ID
- `APP_BUNDLE_ID` = `com.willvesevick.robotrob` (or your final bundle id)
- `ASC_KEY_ID` = App Store Connect API Key ID
- `ASC_ISSUER_ID` = App Store Connect Issuer ID
- `ASC_PRIVATE_KEY_B64` = base64 of your `.p8` file

To create `ASC_PRIVATE_KEY_B64` on Mac:

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | tr -d '\n' | pbcopy
```

Paste clipboard output as the secret value.

## 4. Create App Record (Web)
In App Store Connect:
1. `My Apps` -> `+` -> `New App`
2. Platform: `iOS`
3. Name: `Robot Rob`
4. Bundle ID: must exactly match `APP_BUNDLE_ID`
5. SKU: any unique value (example `robotrob-001`)

## 5. Run Cloud Build
In GitHub:
1. Open `Actions`
2. Select `iOS TestFlight (No Local Xcode)`
3. Click `Run workflow`

If successful, the build uploads to TestFlight automatically.

## 6. Install and Preview on Your iPhone
In App Store Connect:
1. Go to your app -> `TestFlight`
2. Add yourself as an internal tester if not already listed
3. Accept invite in TestFlight app on iPhone
4. Install and test before App Store submission

## Notes
- You can test as many TestFlight builds as needed before submitting for App Review.
- If signing fails in CI, verify key permissions and bundle id match.
- App privacy policy URL for submission: `https://paste.rs/65Y4y`
