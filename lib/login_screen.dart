// Import necessary Flutter and Firebase packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication functionality
import 'home_screen.dart'; // Screen shown after successful login
import 'signup_screen.dart'; // Screen for new user registration
import 'reset_password_screen.dart'; // Screen for password reset functionality
import 'onboarding_screen.dart'; // Screen for first-time user setup
import 'package:cloud_firestore/cloud_firestore.dart'; // For accessing Firestore database

// Define the stateful widget for the login screen
class LoginScreen extends StatefulWidget {
  @override
  // Create the state for this widget
  _LoginScreenState createState() => _LoginScreenState();
}

// Define the state class for the login screen
class _LoginScreenState extends State<LoginScreen> {
  // Initialize Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Create controllers to manage text input fields
  final TextEditingController emailController = TextEditingController();    // Manages email input
  final TextEditingController passwordController = TextEditingController(); // Manages password input

  // Function to handle user login
  Future<void> loginUser() async {
    try {
      // Attempt to sign in user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),    // Remove whitespace from email
        password: passwordController.text.trim(), // Remove whitespace from password
      );
      
      // Check if user needs to complete onboarding
      checkOnboarding(userCredential.user);
    } catch (e) {
      // Show error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    }
  }

  // Function to check if user has completed onboarding
  Future<void> checkOnboarding(User? user) async {
    if (user != null) {
      // Get user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      
      // Check if user has completed onboarding
      bool completedOnboarding = userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>)["completedOnboarding"] == true;
      
      // Navigate to appropriate screen based on onboarding status
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => completedOnboarding ? HomeScreen() : OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the login screen UI
    return Scaffold(
      // Create app bar with login title
      appBar: AppBar(title: Text("Login")),
      
      // Main body of the login screen
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
            
            // Login button
            ElevatedButton(
              onPressed: loginUser, // Call login function when pressed
              child: Text("Login"),
            ),
            
            // Sign up link
            TextButton(
              onPressed: () {
                // Navigate to signup screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: Text("Don't have an account? Sign up"),
            ),
            
            // Password reset link
            TextButton(
              onPressed: () {
                // Navigate to password reset screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                );
              },
              child: Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}