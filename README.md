# Vanish Class Network

## Project Overview

Vanish Class Network is a temporary classroom chat application developed using Flutter and Dart. It allows students to exchange messages through a shared WebSocket relay. Messages are designed to disappear automatically after 30 seconds.

## Features

- Real-time messaging through a WebSocket relay.
- Automatic message expiry after 30 seconds.
- Countdown timer for each message.
- Local message storage using SQLite.
- WebSocket heartbeat and reconnection support.
- Offline message queuing with expiry checking.
- Duplicate message ID checking.

## Technologies Used

- Flutter and Dart
- WebSocket (`web_socket_channel`)
- SQLite (`sqflite`)
- Path (`path`)
- Connectivity Plus (`connectivity_plus`)
- Android Studio

## Platform

Developed using Flutter and Dart in Android Studio and tested on Android physical devices.

## Relay Configuration

- Relay URL: `wss://vanish-relay-sawaira.bonto.page/ws`
- Protocol Version: 1
- Message Lifetime: 30 seconds
- Transport: WebSocket using JSON text frames

See [PROTOCOL.md](PROTOCOL.md) for the protocol specification used by the application.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio
- Android SDK
- Android device or emulator

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/fatima-aamir-cs/vanishclassnetwork_chatapp.git
   ```

2. Open the project folder in Android Studio.

3. Install dependencies:

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

**Project Teammate:** Sundas

## Academic Integrity and Acknowledgements

This project was developed as a Mobile Application Development academic assignment.

External packages used:

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [sqflite](https://pub.dev/packages/sqflite)
- [path](https://pub.dev/packages/path)
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)
- [web_socket_channel](https://pub.dev/packages/web_socket_channel)

AI assistance was used for learning, explanations, and debugging support.

## Limitations

- Users may still take screenshots or copy message content before it disappears.
- Disappearance from the application does not guarantee removal of screenshots or other copies.
- The relay stores messages in memory only and deletes them after their expiry time.
- If a device is switched off or remains disconnected when a message expires, the application cannot guarantee that the message will be displayed when the device reconnects.
- The relay has no password; anyone with its address may be able to join.

## License

Academic project - prepared for educational purposes.