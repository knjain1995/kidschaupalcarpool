// Import required Flutter and Firebase packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication
import 'onboarding_screen.dart'; // Import screen shown after signup

// Create a StatefulWidget for the signup screen
class SignupScreen extends StatefulWidget {
  @override
  // Create the state for this widget
  _SignupScreenState createState() => _SignupScreenState();
}

// Define the state class for the signup screen
class _SignupScreenState extends State<SignupScreen> {
  // Initialize Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Create controllers for managing text input fields
  final TextEditingController emailController = TextEditingController();    // For email input
  final TextEditingController passwordController = TextEditingController(); // For password input

  // Function to handle user registration
  Future<void> registerUser() async {
    try {
      // Attempt to create new user account with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),     // Remove whitespace from email
        password: passwordController.text.trim(), // Remove whitespace from password
      );

      // After successful registration, navigate to onboarding screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    } catch (e) {
      // Show error message if registration fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the signup screen UI
    return Scaffold(
      // Create app bar with signup title
      appBar: AppBar(title: Text("Sign Up")),
      
      // Main body of the signup screen
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around all sides
        child: Column(
          // Center align all children vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email input field
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            
            // Password input field
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true, // Hide password characters
            ),
            
            // Add vertical spacing
            SizedBox(height: 20),
            
            // Signup button
            ElevatedButton(
              onPressed: registerUser, // Call registerUser function when pressed
              child: Text("Sign Up"),
            ),
            
            // Login link for existing users
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Go back to previous screen (login)
              },
              child: Text("Already have an account? Log in"),
            ),
          ],
        ),
      ),
    );
  }
}