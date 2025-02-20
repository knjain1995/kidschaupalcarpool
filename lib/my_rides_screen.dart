import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For fetching rides from Firestore
import 'package:firebase_auth/firebase_auth.dart'; // To get current user

class MyRidesScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  // Function to retrieve rides offered by the current user
  Stream<QuerySnapshot> _getMyRides() {
    return _firestore
        .collection("rides")
        .where("userId", isEqualTo: _auth.currentUser!.uid) // Filter by current user
        .orderBy("createdAt", descending: true) // Order by most recent
        .snapshots(); // Real-time updates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Offered Rides")), // Page title
      body: StreamBuilder<QuerySnapshot>(
        stream: _getMyRides(), // Stream of user-offered rides
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading indicator
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("You haven't offered any rides yet."));
          }

          // Display list of rides
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text("${data['pickup']} ➔ ${data['drop']}"),
                  subtitle: Text(
                      "Date: ${data['departureDate'].toString().split('T')[0]} \nTime: ${data['departureTime']} \nSeats: ${data['seats']} \nPrice: ₹${data['pricePerSeat']} per seat"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
