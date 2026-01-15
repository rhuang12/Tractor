# WillPoints - Xcode Setup Guide

This guide walks you through creating the Xcode project and configuring it to use the Swift files in this repo.

## Prerequisites

- Mac with macOS 14 (Sonoma) or later
- Xcode 15+ (download from Mac App Store)
- Apple ID (free tier is fine for personal use)

## Step 1: Create Xcode Project

1. Open Xcode
2. File → New → Project (⌘⇧N)
3. Choose **iOS → App**
4. Configure:
   - Product Name: `WillPoints`
   - Team: Your Apple ID (or "None" for now)
   - Organization Identifier: `com.yourname` (e.g., `com.johndoe`)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ☐ Uncheck "Include Tests" (optional, for simplicity)
5. Save it in the `WillPoints` folder of this repo

## Step 2: Add Widget Extension

1. File → New → Target (⌘⇧T)
2. Choose **iOS → Widget Extension**
3. Configure:
   - Product Name: `WillPointsWidget`
   - ☐ Uncheck "Include Live Activity"
   - ☐ Uncheck "Include Configuration App Intent"
4. Click Finish
5. When asked "Activate scheme?", click **Activate**

## Step 3: Configure App Groups

Both the app and widget need to share data. This requires an App Group.

### 3a. Create the App Group

1. Click on the project in the Navigator (blue icon at top)
2. Select the **WillPoints** target (the app, not the widget)
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add **App Groups**
6. Click the **+** under App Groups
7. Enter: `group.com.willpoints.shared`
8. Click OK

### 3b. Add App Group to Widget

1. Select the **WillPointsWidgetExtension** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** → **App Groups**
4. Check the same group: `group.com.willpoints.shared`

## Step 4: Replace Generated Files with Repo Files

### Delete Xcode's Generated Files

Delete these files that Xcode created (we'll use our own):
- `WillPoints/ContentView.swift`
- `WillPoints/WillPointsApp.swift`
- `WillPointsWidget/WillPointsWidget.swift`
- `WillPointsWidget/WillPointsWidgetBundle.swift` (if exists)
- `WillPointsWidget/AppIntent.swift` (if exists)

### Add Repo Files to App Target

1. Right-click **WillPoints** folder in Xcode Navigator
2. Select **Add Files to "WillPoints"...**
3. Navigate to `WillPoints/Shared/` and add:
   - `Models/Redemption.swift`
   - `Models/Transaction.swift`
   - `Models/WillPointsData.swift`
   - `Storage/DataManager.swift`
4. **Important:** Check both targets in the dialog:
   - ☑ WillPoints
   - ☑ WillPointsWidgetExtension
5. Navigate to `WillPoints/App/` and add:
   - `WillPointsApp.swift`
   - `Views/MainView.swift`
   - `Views/HistoryView.swift`
   - `Views/SettingsView.swift`
6. For app files, only check the app target:
   - ☑ WillPoints
   - ☐ WillPointsWidgetExtension

### Add Repo Files to Widget Target

1. Navigate to `WillPoints/Widget/` and add:
   - `WillPointsWidget.swift`
   - `WillPointsIntents.swift`
2. Check only the widget target:
   - ☐ WillPoints
   - ☑ WillPointsWidgetExtension

## Step 5: Update App Group Identifier (if different)

If you used a different App Group name, update it in `DataManager.swift`:

```swift
private let appGroupIdentifier = "group.com.willpoints.shared"  // ← Change this
```

## Step 6: Build and Run

1. Select "WillPoints" scheme (not the widget)
2. Choose a simulator (e.g., iPhone 15 Pro)
3. Press ⌘R to build and run

### Test the Widget

1. After app runs, press Home (⌘⇧H in simulator)
2. Long-press on home screen → tap **+** (top left)
3. Search for "WillPoints"
4. Add the small widget

## File Structure Reference

```
WillPoints/
├── SETUP.md                          ← You are here
├── Shared/                           ← Shared between app and widget
│   ├── Models/
│   │   ├── Redemption.swift
│   │   ├── Transaction.swift
│   │   └── WillPointsData.swift
│   └── Storage/
│       └── DataManager.swift
├── App/                              ← App-only files
│   ├── WillPointsApp.swift
│   └── Views/
│       ├── MainView.swift
│       ├── HistoryView.swift
│       └── SettingsView.swift
└── Widget/                           ← Widget-only files
    ├── WillPointsWidget.swift
    └── WillPointsIntents.swift
```

## Target Membership Summary

| File | WillPoints (App) | Widget Extension |
|------|:----------------:|:----------------:|
| Redemption.swift | ✓ | ✓ |
| Transaction.swift | ✓ | ✓ |
| WillPointsData.swift | ✓ | ✓ |
| DataManager.swift | ✓ | ✓ |
| WillPointsApp.swift | ✓ | |
| MainView.swift | ✓ | |
| HistoryView.swift | ✓ | |
| SettingsView.swift | ✓ | |
| WillPointsWidget.swift | | ✓ |
| WillPointsIntents.swift | | ✓ |

## Troubleshooting

### "App Group container not available"

The App Group isn't configured correctly:
1. Check both targets have the App Group capability
2. Verify the identifier matches exactly in both targets
3. Verify `DataManager.swift` uses the same identifier

### Widget not appearing in widget gallery

1. Make sure you ran the app at least once
2. Try: Product → Clean Build Folder (⌘⇧K)
3. Rebuild and run again

### Widget shows placeholder data

The widget can't access the shared data:
1. Check App Group configuration (Step 3)
2. Check file target memberships (Step 4)

### "No such module 'WidgetKit'"

You're trying to import WidgetKit in the main app. Make sure:
- `WillPointsWidget.swift` is only in the widget target
- `WillPointsIntents.swift` is only in the widget target

## Running on Your iPhone

### With Free Apple ID

1. In Xcode, select your project
2. Go to Signing & Capabilities
3. Set Team to your Personal Team (Apple ID)
4. Connect your iPhone via USB
5. On iPhone: Settings → General → Device Management → Trust your developer certificate
6. Select your iPhone as the run destination
7. Press ⌘R

Note: Free provisioning requires re-installing every 7 days.

### With Apple Developer Program ($99/year)

Same process, but apps last 1 year and you can use TestFlight.

## Next Steps

Once it's running:
1. Test adding points (tap balance, tap +1)
2. Test cycling presets (tap the emoji)
3. Test redemption (tap ✓ when you have enough points)
4. Check history in the app
5. Adjust settings (quick add amount, presets)

The widget should update within ~300ms of each tap. If it feels slow, that's the iOS widget system – it's a platform limitation.
