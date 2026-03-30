<div align="center">

# NotiSaver

### Android-only notification history with a cleaner inbox, richer settings, and chat-style viewing

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com/)
[![SQLite](https://img.shields.io/badge/Storage-SQLite-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![Status](https://img.shields.io/badge/Status-Active%20Prototype-4C8BF5)](https://github.com/Azrul16/Notisaver-Flutter-app)

<br />

[![View Repository](https://img.shields.io/badge/View-Repository-111827?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Azrul16/Notisaver-Flutter-app)
[![Star the Repo](https://img.shields.io/badge/Star-the%20Repo-F59E0B?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Azrul16/Notisaver-Flutter-app)
[![Fork the Repo](https://img.shields.io/badge/Fork-NotiSaver-2563EB?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Azrul16/Notisaver-Flutter-app/fork)
[![Open Issues](https://img.shields.io/badge/Issues-Welcome-E11D48?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Azrul16/Notisaver-Flutter-app/issues)

</div>

<br />

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/Azrul16/Notisaver-Flutter-app?style=flat-square)](https://github.com/Azrul16/Notisaver-Flutter-app/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Azrul16/Notisaver-Flutter-app?style=flat-square)](https://github.com/Azrul16/Notisaver-Flutter-app/network/members)
[![GitHub issues](https://img.shields.io/github/issues/Azrul16/Notisaver-Flutter-app?style=flat-square)](https://github.com/Azrul16/Notisaver-Flutter-app/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/Azrul16/Notisaver-Flutter-app?style=flat-square)](https://github.com/Azrul16/Notisaver-Flutter-app/commits/main)

</div>

<br />

<div align="center">
  <img src="https://img.shields.io/badge/LOCAL%20FIRST-NOTIFICATION%20ARCHIVE-1D4ED8?style=for-the-badge" alt="Local first banner" />
  <img src="https://img.shields.io/badge/ANDROID-CHAT--STYLE%20HISTORY-0F766E?style=for-the-badge" alt="Android chat history banner" />
  <img src="https://img.shields.io/badge/MODERN%20UI-ANIMATED%20SURFACES-7C3AED?style=for-the-badge" alt="Modern UI banner" />
</div>

<br />

<table align="center">
  <tr>
    <td width="58%">
      <h2>Why NotiSaver?</h2>
      <p>
        NotiSaver captures Android notifications locally, organizes them into cleaner message and app views,
        and makes old alerts easier to find later without depending on a remote backend.
      </p>
      <p>
        It is designed for people who want a more readable, searchable, and visually richer notification archive
        than the default system tray experience.
      </p>
      <ul>
        <li>Message-style browsing for chat-like notifications</li>
        <li>App-based archive for general alerts</li>
        <li>Modern settings UI with reliability tools and insights</li>
        <li>Local-first storage using SQLite</li>
      </ul>
    </td>
    <td width="42%" align="center">
      <img src="./imagesForGithub/splash%20screen.jpg" alt="NotiSaver splash preview" width="100%" />
    </td>
  </tr>
</table>

## Table of Contents

- [Getting Started In 60 Seconds](#getting-started-in-60-seconds)
- [Screenshots](#screenshots)
- [Feature Comparison](#feature-comparison)
- [Feature Cards](#feature-cards)
- [Core Features](#core-features)
- [How It Works](#how-it-works)
- [Storage and Privacy](#storage-and-privacy)
- [Android Requirements](#android-requirements)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Developer Commands](#developer-commands)
- [Android Build Commands](#android-build-commands)
- [Release / Download](#release--download)
- [Suggested Workflow](#suggested-workflow)
- [Contributing](#contributing)
- [Issues and Feedback](#issues-and-feedback)
- [FAQ](#faq)
- [Status](#status)
- [Support](#support)

## Getting Started In 60 Seconds

Clone the project:

```bash
git clone https://github.com/Azrul16/Notisaver-Flutter-app.git
cd Notisaver-Flutter-app
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run checks:

```bash
flutter analyze
flutter test
```

Build a debug APK:

```bash
flutter build apk --debug
```

## Screenshots

<div align="center">
  <img src="./imagesForGithub/splash%20screen.jpg" alt="Splash screen" width="22%" />
  <img src="./imagesForGithub/messege%20screen.jpg" alt="Message screen" width="22%" />
  <img src="./imagesForGithub/notification.jpg" alt="Notification thread screen" width="22%" />
  <img src="./imagesForGithub/settings.jpg" alt="Settings screen" width="22%" />
</div>

<br />

<div align="center">
  <img src="https://img.shields.io/badge/FAST%20SETUP-READY%20IN%2060%20SECONDS-2563EB?style=for-the-badge" alt="Fast setup banner" />
  <img src="https://img.shields.io/badge/SEARCH-SMART%20FILTERS-0891B2?style=for-the-badge" alt="Smart filters banner" />
  <img src="https://img.shields.io/badge/SETTINGS-RICH%20CONTROL%20CENTER-9333EA?style=for-the-badge" alt="Settings banner" />
</div>

## Feature Comparison

| Area | What You Get |
| --- | --- |
| `Messages` | Conversation-style grouping, unread/read switching, quick filters, search, favorites |
| `Apps` | App-grouped notification archive, optional grouping behavior, searchable history |
| `Settings` | Theme controls, search preferences, app filter, reliability tools, notification insights |
| `Storage` | Local-only persistence, duplicate reduction, normalized notification text, SQLite-backed archive |
| `UI / UX` | Animated surfaces, richer cards, modern settings panels, chat-style history screen |

## Feature Cards

<table>
  <tr>
    <td width="33%">
      <h3>Messages</h3>
      <p>Browse notifications like conversations with filters, search, favorites, and read-state awareness.</p>
    </td>
    <td width="33%">
      <h3>Apps</h3>
      <p>Review alerts by app, keep archives organized, and quickly jump through grouped notification history.</p>
    </td>
    <td width="33%">
      <h3>Settings</h3>
      <p>Control appearance, search, reliability tools, app exclusions, and notification insights in one place.</p>
    </td>
  </tr>
  <tr>
    <td width="33%">
      <h3>Local First</h3>
      <p>Notifications stay on-device using SQLite-backed storage rather than a hosted sync backend.</p>
    </td>
    <td width="33%">
      <h3>Android Native Bridge</h3>
      <p>Kotlin platform integration powers notification listening, reliability checks, and system settings access.</p>
    </td>
    <td width="33%">
      <h3>Modern UI</h3>
      <p>Animated cards, darker thread screens, richer controls, and a more attractive utility-app experience.</p>
    </td>
  </tr>
</table>

## Core Features

### Messages

- Conversation-style grouping
- Unread/read switching
- Quick filters for:
  - `Messages`
  - `Calls`
  - `OTP`
  - `Social`
- Search based on the selected search mode
- Favorite/save support and read-state tracking

### Apps

- App-grouped notification feed
- Optional grouped or more granular browsing behavior
- Searchable app and notification archive

### Settings

- Theme controls
- Search preferences
- Unread-first and grouping controls
- App exclusion management
- Notification insights
- Background reliability and listener-health tools

### UI / UX

- Modern card-based layout
- Animated transitions using `flutter_animate`
- Darker thread-style history screens
- More visual settings controls instead of plain text lists

## How It Works

1. The app requests notification access.
2. Android forwards notifications through a native notification-listener service.
3. Flutter receives notification payloads through platform channels.
4. Notifications are normalized, deduplicated, and stored locally.
5. The UI presents them in `Messages`, `Apps`, and `Settings`.

## Storage and Privacy

- Notifications are stored locally on the device
- Data is not uploaded to a backend by default
- SQLite is used for persistence
- Text is normalized and trimmed before storage
- Older notifications are purged using the app’s fixed retention policy

## Android Requirements

NotiSaver depends on:

- notification listener access
- battery optimization exemption support on stricter devices
- restart/update recovery support through boot/package-replaced handling

Some Android vendors may still require additional background or auto-start permissions.

## Tech Stack

- Flutter
- Dart
- Kotlin
- `sqflite`
- `shared_preferences`
- `flutter_animate`

## Project Structure

```text
lib/
  app.dart
  main.dart
  core/
    theme/
  data/
    database/
    models/
    repositories/
  features/
    notifications/
    permissions/
    settings/
    splash/
  services/

android/
  app/
```

## Developer Commands

Install dependencies:

```bash
flutter pub get
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Clean generated files and restore packages:

```bash
flutter clean
flutter pub get
```

Check outdated packages:

```bash
flutter pub outdated
```

## Android Build Commands

Build debug APK:

```bash
flutter build apk --debug
```

Build release APK:

```bash
flutter build apk --release
```

Build Android App Bundle:

```bash
flutter build appbundle --release
```

Install on a connected device:

```bash
flutter install
```

## Release / Download

If you want to prepare distributable Android builds:

Debug APK:

```bash
flutter build apk --debug
```

Release APK:

```bash
flutter build apk --release
```

Release App Bundle:

```bash
flutter build appbundle --release
```

Recommended next step:

- Publish generated release artifacts through the GitHub Releases page for easier download and sharing.

## Suggested Workflow

```bash
git clone https://github.com/Azrul16/Notisaver-Flutter-app.git
cd Notisaver-Flutter-app
flutter pub get
flutter analyze
flutter test
flutter run
```

## Contributing

Contributions are welcome.

If you want to improve the UI, optimize notification processing, add device-specific fixes, or polish the Android experience:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run:

```bash
flutter analyze
flutter test
```

5. Open a pull request

## Issues and Feedback

Found a bug, device-specific reliability issue, or UI improvement idea?

- Open an issue on GitHub
- Include your device model and Android version when relevant
- Add screenshots/logs when reporting visual or notification-listener problems

Repository issues page:

- https://github.com/Azrul16/Notisaver-Flutter-app/issues

## FAQ

### Is NotiSaver Android-only?

Yes. The project is built around Android notification-listener access, so the core experience is intended for Android devices.

### Does NotiSaver upload my notifications anywhere?

No by default. Notifications are stored locally on-device using SQLite.

### Why does the app need notification access?

Android requires notification-listener permission for apps that want to read and archive incoming notifications.

### Why is battery optimization important?

Some Android devices aggressively stop background services. Exempting the app from battery optimization can improve notification capture reliability.

### Why might behavior differ across phones?

Device brands often customize Android background rules. Auto-start, background protection, and battery settings may affect reliability.

### Where are notifications shown inside the app?

They are organized into:

- `Messages` for conversation-like notifications
- `Apps` for app-grouped notifications
- `Settings` for preferences, reliability, and insights

### How do I build an APK?

Use:

```bash
flutter build apk --debug
```

or for release:

```bash
flutter build apk --release
```

## Status

This project is currently in a strong MVP / polished prototype stage:

- local notification capture is working
- the core UI has been modernized and animated
- Android debug builds are passing
- baseline automated tests are in place

It is ready for more device testing, cleanup, and release preparation.

## Support

<div align="center">

## Support NotiSaver

If you like the project, want to follow updates, or want to build your own version, these help a lot:

[![Star the Repo](https://img.shields.io/badge/STAR-NotiSaver-F59E0B?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Azrul16/Notisaver-Flutter-app)
[![Fork the Repo](https://img.shields.io/badge/FORK-Build%20Your%20Version-2563EB?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Azrul16/Notisaver-Flutter-app/fork)
[![Open an Issue](https://img.shields.io/badge/FEEDBACK-Open%20an%20Issue-E11D48?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Azrul16/Notisaver-Flutter-app/issues)

</div>

<table align="center">
  <tr>
    <td width="33%" align="center">
      <h3>Star</h3>
      <p>Show support and make the project easier for others to discover.</p>
    </td>
    <td width="33%" align="center">
      <h3>Fork</h3>
      <p>Create your own version, experiment with features, and build on the idea.</p>
    </td>
    <td width="33%" align="center">
      <h3>Feedback</h3>
      <p>Report bugs, suggest features, and help improve device reliability.</p>
    </td>
  </tr>
</table>

<div align="center">

Repository: https://github.com/Azrul16/Notisaver-Flutter-app

</div>
