# Smart Student Organizer

A Flutter-based student productivity app focused on simple academic planning. The app includes a student login screen, dashboard overview, task manager, profile editing, notes upload flow, dark mode, and basic English/Hindi language switching.

## Overview

This project is a multi-platform Flutter application built for students who want one place to manage everyday study activities. It currently works as a lightweight organizer with a clean dashboard and a few core academic tools.

## Features

- Student-style login entry screen
- Dashboard with date, summary cards, recent tasks, and attendance progress
- Task management with add and delete support
- Focus timer card on the home screen
- Profile screen with editable name and profile photo selection from gallery
- Notes section with local file picking support
- Light and dark theme toggle
- English and Hindi language toggle
- Flutter support for Android, iOS, Web, Windows, Linux, and macOS project structure

## Screens Included

- Login screen
- Home dashboard
- Tasks screen
- Schedule tab
- Notes tab
- Profile screen

## Tech Stack

- Flutter
- Dart
- Material 3
- `intl`
- `flutter_localizations`
- `image_picker`
- `file_picker`

## Project Structure

```text
lib/
  main.dart          # Main app UI and state handling
test/
  widget_test.dart   # Starter widget test
android/             # Android platform files
ios/                 # iOS platform files
web/                 # Web platform files
linux/ macos/        # Desktop platform files
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK included with Flutter
- Android Studio or VS Code
- A connected emulator, simulator, or physical device

Check Flutter setup:

```bash
flutter doctor
```

### Installation

1. Clone the repository:

```bash
git clone <your-repository-url>
cd mock
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Useful Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Current Behavior and Notes

- App state is currently stored in memory, so tasks and profile changes do not persist after restart.
- The Schedule tab is present in the UI but currently acts as a placeholder.
- Login is UI-based and does not use backend authentication.
- Notes upload currently stores selected file names in the running session only.

## Why This Project Is Useful

This project is a good starter app for:

- Flutter UI practice
- Student productivity app ideas
- Learning state management with `StatefulWidget`
- Adding localization, theming, file picking, and image picking in one project

## Future Improvements

- Add local database support with Hive or SQLite
- Add real authentication
- Build a working study timer
- Add task completion tracking
- Add calendar-based scheduling
- Persist uploaded notes and profile data
- Improve localization using ARB files
