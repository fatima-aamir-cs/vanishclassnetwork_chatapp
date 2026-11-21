
import 'package:flutter/material.dart';
import 'screens/join_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VanishApp());
}

class VanishApp extends StatelessWidget {
  const VanishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vanish Class Network',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B7CF6),
        ),
        useMaterial3: true,
      ),
      home: const JoinScreen(),
    );
  }
}
