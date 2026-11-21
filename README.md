# Vanish Class Network

## Project Overview
Vanish Class Network is a temporary classroom chat application developed using Flutter and Dart. It allows students to exchange messages that automatically disappear after 30 seconds.

The application is designed to support temporary communication within a classroom environment.

## Features
- Real-time messaging through a WebSocket relay.
- Automatic message expiry after 30 seconds.
- Countdown timer for each message.
- Local message storage using SQLite.
- Reconnection and heartbeat support.

## Technologies Used
- Flutter
- Dart
- WebSocket
- SQLite
- Android Studio

## Platform
Developed using Flutter in Android Studio and tested on Android physical devices.

## Relay Configuration
- Relay URL: `wss://vanish-relay-sawaira.bonto.page/ws`
- Protocol Version: 1
- Message Lifetime: 30 seconds

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio
- Android SDK

### Installation

1. Clone this repository:
   ```bash
   git clone YOUR_REPOSITORY_URL
   ```

2. Open the project folder in Android Studio.

3. Get the required dependencies:
   ```bash
   flutter pub get
   ```

4. Connect an Android device or start an emulator.

5. Run the application:
   ```bash
   flutter run
   ```

## Team

**Developer:** Fatima Aamir  
Application development and source code implementation.

**Collaborator:** Sundas  
Project teammate and GitHub repository collaborator.

## Academic Integrity and Acknowledgements

This project was developed as an academic assignment. External libraries and tools used in development should be acknowledged with their relevant documentation links. AI assistance was used for learning, explanations, and debugging support. The submitted implementation was developed and reviewed by the developer.

## Limitations

- The application cannot prevent users from taking screenshots or copying message content.
- Message disappearance from the application does not guarantee removal of every possible copy.
- Message availability may be affected when a device is offline or switched off.

## License
Academic project – prepared for educational purposes.