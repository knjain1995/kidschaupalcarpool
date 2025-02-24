import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RideDetailsScreen extends StatefulWidget {
  final String rideId; // Ride ID passed from Search Screen

  RideDetailsScreen({required this.rideId});

  @override
  _RideDetailsScreenState createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? rideData;
  bool isLoading = true;
  String requestStatus = "none"; // Tracks user's request status (none/requested/accepted/rejected)

  @override
  void initState() {
    super.initState();
    _loadRideDetails();
  }

  // Fetch ride details & user request status
  Future<void> _loadRideDetails() async {
    try {
      DocumentSnapshot rideSnapshot =
          await _firestore.collection("rides").doc(widget.rideId).get();
      setState(() {
        rideData = rideSnapshot.data() as Map<String, dynamic>;
        isLoading = false;
      });
      _checkRequestStatus();
    } catch (e) {
      print("Error loading ride details: $e");
    }
  }

  // Check if user already requested this ride
  Future<void> _checkRequestStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot requestSnapshot = await _firestore
          .collection("rides")
          .doc(widget.rideId)
          .collection("requests")
          .where("userId", isEqualTo: user.uid)
          .get();

      if (requestSnapshot.docs.isNotEmpty) {
        setState(() {
          requestStatus = requestSnapshot.docs.first["status"];
        });
      }
    }
  }

  // Request a ride (creates Firestore entry)
  Future<void> _requestRide() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection("rides")
          .doc(widget.rideId)
          .collection("requests")
          .doc(user.uid)
          .set({
        "userId": user.uid,
        "status": "requested",
        "requestedAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        requestStatus = "requested"; // Update UI after requesting
      });
    }
  }

  // Cancel a ride request
  Future<void> _cancelRequest() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection("rides")
          .doc(widget.rideId)
          .collection("requests")
          .doc(user.uid)
          .delete();

      setState(() {
        requestStatus = "none"; // Reset UI after cancellation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ride Details")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("From: ${rideData!['pickup']}", style: TextStyle(fontSize: 18)),
                  Text("To: ${rideData!['drop']}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(rideData!['departureDate']))}"),
                  Text("Time: ${rideData!['departureTime']}"),
                  Text("Seats Available: ${rideData!['seats']}"),
                  Text("Price per Seat: ₹${rideData!['pricePerSeat']}"),
                  SizedBox(height: 20),

                  // 🖱️ Request / Cancel button logic based on request status
                  if (requestStatus == "none")
                    ElevatedButton(
                      onPressed: _requestRide,
                      child: Text("Request Ride"),
                    )
                  else if (requestStatus == "requested")
                    ElevatedButton(
                      onPressed: _cancelRequest,
                      child: Text("Cancel Request"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    )
                  else if (requestStatus == "accepted")
                    Text("✅ Your request has been accepted! 🎉", style: TextStyle(color: Colors.green, fontSize: 16))
                  else if (requestStatus == "rejected")
                    Text("❌ Your request was rejected.", style: TextStyle(color: Colors.red, fontSize: 16)),
                ],
              ),
            ),
    );
  }
}
