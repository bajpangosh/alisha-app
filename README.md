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

1.  **Update `pubspec.yaml`**: Change the `name` and `description` fields.
2.  **Use the `rename` utility** (recommended):

    ```bash
    # Install the rename package globally
    flutter pub global activate rename

    # Run the rename command
    flutter pub global run rename --bundleId com.yourcompany.yourapp --appname "Your App Name"
    ```

3.  **Manual Method**:
    *   **Android**: Update `android/app/build.gradle` (`applicationId`) and `android/app/src/main/AndroidManifest.xml` (`android:label`).
    *   **iOS**: Update `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`) and `ios/Runner/Info.plist` (`CFBundleDisplayName`).

### 4. Firebase Configuration

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

### 5. Building with Codemagic

Codemagic is recommended for automating your builds for the Play Store and App Store.

1.  **Sign Up/Login** to [Codemagic.io](https://codemagic.io/).
2.  **Add Application**: Connect your GitHub repository (`bajpangosh/alisha-app`).
3.  **Configure Workflow**:
    *   Select **Flutter App**.
    *   **Build Triggers**: Set to trigger on push to `main`.
    *   **Environment Variables**: Add any keys if necessary (though most config is pulled dynamically from your WP site).
4.  **Distribution**:
    *   **Android**: Upload your Keystore (`.jks`) and set alias/passwords in the Codemagic "Distribution > Android Code Signing" section.
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
