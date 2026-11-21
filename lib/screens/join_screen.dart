
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController _nameController =
  TextEditingController();

  void _joinClass() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(username: name),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101426),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.visibility_off_rounded,
                  size: 75,
                  color: Color(0xFF9B8CFF),
                ),

                const SizedBox(height: 20),

                const Text(
                  'VANISH',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'CLASS CHAT NETWORK',
                  style: TextStyle(
                    color: Colors.white60,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 55),

                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your display name',
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF9B8CFF),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF202941),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _joinClass(),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _joinClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B7CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'JOIN CLASS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Messages disappear after delivery.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
