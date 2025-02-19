// Import required Flutter and Firebase packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For storing user data
import 'package:firebase_auth/firebase_auth.dart';     // For user authentication
import 'home_screen.dart';                             // For navigation after onboarding

// Create a StatefulWidget for the onboarding screen
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

// Define the state class for the onboarding screen
class _OnboardingScreenState extends State<OnboardingScreen> {
  // Initialize text controllers for user input fields
  final TextEditingController phoneController = TextEditingController();        // For phone number
  final TextEditingController carMakeController = TextEditingController();      // For car make
  final TextEditingController carModelController = TextEditingController();     // For car model
  final TextEditingController carColorController = TextEditingController();     // For car color
  final TextEditingController licensePlateController = TextEditingController(); // For license plate
  
  // Initialize default values for dropdown preferences
  String musicPreference = "No Preference";    // Default music preference
  String smokingPreference = "No Preference";  // Default smoking preference

  // Function to save user data to Firestore
  Future<void> saveUserData() async {
    // Get current logged in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Save user data to Firestore document
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "email": user.email,                              // User's email
        "phone": phoneController.text.trim(),             // Phone number
        "carMake": carMakeController.text.trim(),        // Car make
        "carModel": carModelController.text.trim(),       // Car model
        "carColor": carColorController.text.trim(),       // Car color
        "licensePlate": licensePlateController.text.trim(), // License plate
        "musicPreference": musicPreference,               // Music preference
        "smokingPreference": smokingPreference,           // Smoking preference
        "completedOnboarding": true                       // Mark onboarding as done
      });

      // Navigate to home screen after saving data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the onboarding screen UI
    return Scaffold(
      // Create app bar with title
      appBar: AppBar(title: Text("Complete Your Profile")),
      
      // Make the form scrollable
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0), // Add padding around all sides
        child: Column(
          children: [
            // Phone number input field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone, // Show number keyboard
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            
            // Car make input field
            TextField(
              controller: carMakeController,
              decoration: InputDecoration(labelText: "Car Make (e.g., Toyota)"),
            ),
            
            // Car model input field
            TextField(
              controller: carModelController,
              decoration: InputDecoration(labelText: "Car Model (e.g., Corolla)"),
            ),
            
            // Car color input field
            TextField(
              controller: carColorController,
              decoration: InputDecoration(labelText: "Car Color"),
            ),
            
            // License plate input field
            TextField(
              controller: licensePlateController,
              decoration: InputDecoration(labelText: "License Plate"),
            ),
            
            SizedBox(height: 10), // Vertical spacing

            // Dropdown for music preference
            DropdownButtonFormField(
              value: musicPreference,
              items: ["No Preference", "Soft Music", "No Music"]
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item)
                      ))
                  .toList(),
              onChanged: (value) => setState(() => musicPreference = value.toString()),
              decoration: InputDecoration(labelText: "Music Preference"),
            ),

            // Dropdown for smoking preference
            DropdownButtonFormField(
              value: smokingPreference,
              items: ["No Preference", "Non-Smoking Only", "Smoking Allowed"]
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item)
                      ))
                  .toList(),
              onChanged: (value) => setState(() => smokingPreference = value.toString()),
              decoration: InputDecoration(labelText: "Smoking Preference"),
            ),
            
            SizedBox(height: 20), // Additional vertical spacing

            // Save button
            ElevatedButton(
              onPressed: saveUserData, // Call saveUserData when pressed
              child: Text("Complete Profile"),
            ),
          ],
        ),
      ),
    );
  }
}