// Import required Flutter and Firebase packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For storing user data
import 'package:firebase_auth/firebase_auth.dart';     // For user authentication

// Create a StatefulWidget for the profile edit screen
class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

// Define the state class for the profile edit screen
class _ProfileEditScreenState extends State<ProfileEditScreen> {
  // Initialize Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize controllers for text input fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController carMakeController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController carColorController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();
  
  // Initialize default values for preferences
  String musicPreference = "No Preference";
  String smokingPreference = "No Preference";
  
  // Loading state indicator
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load existing user data when screen initializes
  }

  // Function to load user's existing profile data
  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
      
      if (userDoc.exists) {
        // Cast document data to Map
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        
        // Update state with existing data
        setState(() {
          phoneController.text = data["phone"] ?? "";
          carMakeController.text = data["carMake"] ?? "";
          carModelController.text = data["carModel"] ?? "";
          carColorController.text = data["carColor"] ?? "";
          licensePlateController.text = data["licensePlate"] ?? "";
          musicPreference = data["musicPreference"] ?? "No Preference";
          smokingPreference = data["smokingPreference"] ?? "No Preference";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }
  }

  // Function to save updated profile data
  Future<void> _updateUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Update user document in Firestore
      await _firestore.collection("users").doc(user.uid).update({
        "phone": phoneController.text.trim(),
        "carMake": carMakeController.text.trim(),
        "carModel": carModelController.text.trim(),
        "carColor": carColorController.text.trim(),
        "licensePlate": licensePlateController.text.trim(),
        "musicPreference": musicPreference,
        "smokingPreference": smokingPreference,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile Updated Successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the profile edit screen UI
    return Scaffold(
      // Create app bar with title
      appBar: AppBar(title: Text("Edit Profile")),
      
      // Show loading indicator or form based on loading state
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Phone number input field
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: "Phone Number"),
                  ),
                  
                  // Car details input fields
                  TextField(
                    controller: carMakeController,
                    decoration: InputDecoration(labelText: "Car Make"),
                  ),
                  TextField(
                    controller: carModelController,
                    decoration: InputDecoration(labelText: "Car Model"),
                  ),
                  TextField(
                    controller: carColorController,
                    decoration: InputDecoration(labelText: "Car Color"),
                  ),
                  TextField(
                    controller: licensePlateController,
                    decoration: InputDecoration(labelText: "License Plate"),
                  ),
                  
                  SizedBox(height: 10),

                  // Music preference dropdown
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

                  // Smoking preference dropdown
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
                  
                  SizedBox(height: 20),

                  // Save changes button
                  ElevatedButton(
                    onPressed: _updateUserProfile,
                    child: Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}