import 'package:flutter/material.dart';
import '../user_database_helper.dart';

class SignUpScreen extends StatefulWidget {
  final Function(String houseName) onSignUpSuccess;
  const SignUpScreen({super.key, required this.onSignUpSuccess});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _houseNameController = TextEditingController();
  String? _errorMessage;

  void _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final houseName = _houseNameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        houseName.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    // Insert user into the database.
    Map<String, dynamic> row = {
      UserDatabaseHelper.columnEmail: email,
      UserDatabaseHelper.columnPassword: password,
      UserDatabaseHelper.columnHouseName: houseName,
    };

    final dbHelper = UserDatabaseHelper.instance;
    try {
      await dbHelper.insertUser(row);
      // Notify success and then remove all routes so the app shows the HomeScreen.
      widget.onSignUpSuccess(houseName);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error signing up: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
              ),
              TextField(
                controller: _houseNameController,
                decoration: const InputDecoration(labelText: 'House Name'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
            ],
          ),
        ),
      ),
    );
  }
}
