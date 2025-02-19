// Import required Flutter and Firebase packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication
import 'login_screen.dart';                        // For logout navigation
import 'profile_edit_screen.dart';                 // For profile editing

// Create a StatelessWidget for the profile screen
class ProfileScreen extends StatelessWidget {
  // Get the currently logged-in user from Firebase
  final User? user = FirebaseAuth.instance.currentUser;

  // Function to handle user logout
  void logout(BuildContext context) {
    // Sign out the current user from Firebase
    FirebaseAuth.instance.signOut();
    
    // Navigate to login screen and replace current screen in stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the profile screen UI
    return Scaffold(
      // Create app bar with title
      appBar: AppBar(title: Text("Profile")),
      
      // Main body of the profile screen
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around all sides
        child: Column(
          // Center content vertically in the column
          mainAxisAlignment: MainAxisAlignment.center,
          // Align content to the left horizontally
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user's email or 'Unknown' if email is null
            Text(
              "Email: ${user?.email ?? 'Unknown'}", 
              style: TextStyle(fontSize: 18)
            ),
            
            // Add vertical spacing
            SizedBox(height: 20),
            
            // Button to navigate to edit profile screen
            ElevatedButton(
              onPressed: () {
                // Navigate to profile edit screen while keeping current screen in stack
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                );
              },
              child: Text("Edit Profile"),
            ),
            
            // Add vertical spacing
            SizedBox(height: 10),
            
            // Logout button
            ElevatedButton(
              onPressed: () => logout(context), // Call logout function when pressed
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}