// Import required Flutter and Firebase packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication
import 'profile_screen.dart'; // Screen for user profile
import 'login_screen.dart'; // Screen to return to after logout
import 'offer_ride_screen.dart'; // Offer Ride screen
import 'my_rides_screen.dart'; // My Rides screen

// Create a StatelessWidget for the home screen
class HomeScreen extends StatelessWidget {
  // Initialize Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle user logout
  void logout(BuildContext context) {
    // Sign out the current user from Firebase
    _auth.signOut();
    
    // Navigate to login screen and replace current screen in stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the home screen UI
    return Scaffold(
      // Create app bar with title and action buttons
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          // Profile button in app bar
          IconButton(
            icon: Icon(Icons.person), // Person icon for profile
            onPressed: () {
              // Navigate to profile screen while keeping current screen in stack
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          // Logout button in app bar
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () => logout(context), // Call logout function when pressed
          ),
        ],
      ),
      // Main body of the home screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
          children: [
            // Button to offer a ride
            ElevatedButton.icon(
              icon: Icon(Icons.add_circle_outline), // Icon for Offer Ride
              label: Text("Offer a Ride"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OfferRideScreen()), // Navigate to Offer Ride screen
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
            ),
            SizedBox(height: 20), // Spacing between buttons

            // Button to view user's rides
            ElevatedButton.icon(
              icon: Icon(Icons.directions_car), // Icon for My Rides
              label: Text("My Rides"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyRidesScreen()), // Navigate to My Rides screen
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
            ),
          ],
        ),
      ),
    );
  }
}