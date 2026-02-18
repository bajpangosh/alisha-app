# Alisha App

Alisha App is a premium, high-performance Flutter application designed to convert your WordPress website into a native mobile experience (Android & iOS). It works in tandem with the **Alisha WP Plugin** to provide dynamic configuration, onboarding flows, and real-time updates.

## 🚀 Getting Started

### 1. WordPress Plugin Installation

The app relies on the Alisha WordPress Plugin for its configuration and content.

1.  Go to your WordPress Admin Dashboard.
2.  Navigate to **Plugins > Add New**.
3.  Click **Upload Plugin** and select the `alisha-wp-plugin` zip file (ensure you have zipped the plugin directory).
4.  **Activate** the plugin.
5.  Go to the **Alisha App** menu in your dashboard to configure your App Name, Colors, Menus, and Onboarding screens.

### 2. Project Setup

Clone the repository and install dependencies:

```bash
git clone https://github.com/bajpangosh/alisha-app.git
cd alisha-app
flutter pub get
```

### 3. Rename the App

To customize the app's package name and display name for your brand:

1.  **Install the `rename` package globally**:

    ```bash
    flutter pub global activate rename
    ```

2.  **Use the `rename` utility** (recommended):

    ```bash
    # Set bundle/application id
    rename setBundleId --value com.yourcompany.yourapp

    # Set app display name
    rename setAppName --value "Your App Name"
    ```

3.  **Update `pubspec.yaml`**: Change the `name` and `description` fields.

4.  **Manual Method** (if you don't want to use `rename`):
    *   **Android**: Update `android/app/build.gradle` (`applicationId`) and `android/app/src/main/AndroidManifest.xml` (`android:label`).
    *   **iOS**: Update `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`) and `ios/Runner/Info.plist` (`CFBundleDisplayName`).

### 4. App Icon Customization

The project uses `flutter_launcher_icons` to generate icons for Android, iOS, web, Windows, and macOS.

1.  Replace the source icon at:
    *   `assets/icons/alisha_app_icon.png` (recommended: 1024x1024 PNG)
2.  Regenerate platform icons:
    ```bash
    flutter pub get
    dart run flutter_launcher_icons
    ```

### 5. Change Website URL

The app is pre-configured to point to a demo site. You can configure URLs in two ways:

1.  **Recommended (CI/CD via Codemagic): pass build-time env values with `--dart-define`**
    ```bash
    --dart-define=ALISHA_APP_NAME=Your App Name
    --dart-define=ALISHA_APP_ID=com.yourcompany.yourapp
    --dart-define=ALISHA_API_APP_ID=com.kloudboy.alisha
    --dart-define=ALISHA_BASE_WEB_URL=https://your-website.com
    --dart-define=ALISHA_API_BASE_URL=https://your-website.com/wp-json/alisha/v1
    ```
    `ALISHA_API_APP_ID` should match the app-id expected by your WordPress plugin endpoint validation.
    If `ALISHA_API_BASE_URL` is omitted, it is auto-derived from `ALISHA_BASE_WEB_URL`.

2.  **Manual fallback in code**
    Open `lib/config/app_config.dart` and update defaults if needed:
    ```dart
    baseWebUrl: 'https://your-website.com',
    apiBaseUrl: 'https://your-website.com/wp-json/alisha/v1',
    ```

> **Important**: Keep the `/wp-json/alisha/v1` suffix for `apiBaseUrl` when setting it manually.

### 6. Firebase Configuration

This app uses Firebase for Analytics, Crashlytics, and (optional) Push Notifications. You need to link it to your own Firebase project.

1.  Install the Firebase CLI (if you haven't already):
    ```bash
    npm install -g firebase-tools
    firebase login
    ```
2.  Install the FlutterFire CLI:
    ```bash
    dart pub global activate flutterfire_cli
    ```
3.  **Run the configuration command** in the project root:
    ```bash
    flutterfire configure
    ```
    *   Select your Firebase Project.
    *   Select the platforms (Android & iOS).
    *   This will automatically update `lib/firebase_options.dart` and download the necessary `google-services.json` / `GoogleService-Info.plist` files.

### 7. Building with Codemagic

Codemagic is recommended for automating your builds for the Play Store and App Store.

1.  **Sign Up/Login** to [Codemagic.io](https://codemagic.io/).
2.  **Add Application**: Connect your GitHub repository (`bajpangosh/alisha-app`).
3.  **Configure Workflow**:
    *   Select **Flutter App**.
    *   **Build Triggers**: Set to trigger on push to `main`.
    *   **Environment Variables**: Add:
        * `ALISHA_APP_NAME=Your App Name`
        * `ALISHA_APP_ID=com.yourcompany.yourapp`
        * `ALISHA_API_APP_ID=com.kloudboy.alisha`
        * `ALISHA_BASE_WEB_URL=https://your-website.com`
        * `ALISHA_API_BASE_URL=https://your-website.com/wp-json/alisha/v1` (optional if you want auto-derive)
    *   Add these to Flutter build arguments:
        * `--dart-define=ALISHA_APP_NAME=$ALISHA_APP_NAME`
        * `--dart-define=ALISHA_APP_ID=$ALISHA_APP_ID`
        * `--dart-define=ALISHA_API_APP_ID=$ALISHA_API_APP_ID`
        * `--dart-define=ALISHA_BASE_WEB_URL=$ALISHA_BASE_WEB_URL`
        * `--dart-define=ALISHA_API_BASE_URL=$ALISHA_API_BASE_URL`
    *   Optional: use the included `codemagic.yaml` in project root for reproducible workflows.
4.  **Distribution**:
    *   **Android**: Upload your Keystore (`.jks`) and set alias/passwords in the Codemagic "Distribution > Android Code Signing" section.
        * The project reads release signing from `android/key.properties` when present.
    *   **iOS**: Connect your Apple Developer Account to handle signing automatically.
5.  **Start Build**: Click "Start new build" to generate your `.aab` (Android) or `.ipa` (iOS) files.

## 🛠 Tech Stack

*   **Framework**: Flutter (Dart)
*   **State Management**: Provider
*   **Web Integration**: `webview_flutter`
*   **Backend**: WordPress (Alisha Plugin) via REST API
*   **Design**: Material 3 (Google Fonts Inter)

## 📦 Release

To build locally for release (without Codemagic):

```bash
# Android App Bundle
flutter build appbundle --release --no-tree-shake-icons

# iOS Archive (requires macOS)
flutter build ipa --release --no-tree-shake-icons
```
