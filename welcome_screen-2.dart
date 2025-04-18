import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'sign_in_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final Function(String houseName) onAuthSuccess;
  const WelcomeScreen({super.key, required this.onAuthSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Smart Home App',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => LoginScreen(onLoginSuccess: onAuthSuccess),
                    ),
                  );
                },
                child: const Text('Log In'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => SignUpScreen(onSignUpSuccess: onAuthSuccess),
                    ),
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
