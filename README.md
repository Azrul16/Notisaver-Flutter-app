# NotiSaver

NotiSaver is a personal Android-only notification saver built with Flutter. It listens for incoming notifications, stores them locally on the device, and presents them in a cleaner inbox-style experience with separate views for messages and app-grouped notifications.

## Features

- Save notifications locally for later viewing
- Separate `Messages` and `Apps` navigation
- Inbox-style message list with favorites and read state
- App-wise grouped notification view
- Search saved notifications
- Mark all notifications as read
- Delete any notification manually
- Auto-delete notifications older than 30 days by default
- App filter support
- Dark commercial-style UI

## Tech Stack

- Flutter for app UI
- Kotlin/Android platform channels for native integration
- `sqflite` for local storage
- `shared_preferences` for lightweight app settings

## Project Structure

```text
lib/
  app.dart
  main.dart
  core/
  data/
  features/
  services/
```

## Current App Flow

1. Splash screen
2. Welcome screen
3. Permission setup
4. Home screen
   - `Messages` tab for message-like notifications
   - `Apps` tab for notifications grouped by app
5. Notification detail
6. Settings and app filter

## Storage Behavior

- Notifications are stored locally only
- Old notifications are automatically removed after 30 days by default
- Duplicate or repeated notifications are reduced before storage
- Stored text is trimmed to avoid wasting space
- The database is indexed for faster loading

## Android Permissions

To work properly, NotiSaver needs:

- Notification access
- Battery optimization exemption recommended on some devices

Some Android brands may also require auto-start or background protection settings to be adjusted manually.

## Run the Project

```bash
flutter pub get
flutter run
```

## Verify the Project

```bash
flutter analyze
```

## Notes

- This app is built specifically for Android
- Some notification avatars depend on what the source app exposes to Android
- Background reliability varies by device brand and battery restrictions

## Status

This project is currently set up as an MVP with a polished UI and local notification history workflow. It is ready for further refinement, device testing, and release preparation.
