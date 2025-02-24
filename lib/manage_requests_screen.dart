import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageRequestsScreen extends StatefulWidget {
  @override
  _ManageRequestsScreenState createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all rides offered by the logged-in user
  Stream<QuerySnapshot> _getUserRides() {
    return _firestore
        .collection("rides")
        .where("userId", isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }

  // Fetch requests for a specific ride (subcollection 'requests')
  Stream<QuerySnapshot> _getRideRequests(String rideId) {
    return _firestore
        .collection("rides")
        .doc(rideId)
        .collection("requests")
        .snapshots();
  }

  // Accept a ride request
  Future<void> _acceptRequest(String rideId, String requestId) async {
    await _firestore
        .collection("rides")
        .doc(rideId)
        .collection("requests")
        .doc(requestId)
        .update({"status": "accepted"});
  }

  //  Reject a ride request
  Future<void> _rejectRequest(String rideId, String requestId) async {
    await _firestore
        .collection("rides")
        .doc(rideId)
        .collection("requests")
        .doc(requestId)
        .update({"status": "rejected"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Ride Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUserRides(), // Fetches rides owned by the user
        builder: (context, rideSnapshot) {
          if (rideSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!rideSnapshot.hasData || rideSnapshot.data!.docs.isEmpty) {
            return Center(child: Text("You haven't offered any rides yet."));
          }

          // Show list of user-offered rides
          return ListView(
            children: rideSnapshot.data!.docs.map((rideDoc) {
              Map<String, dynamic> rideData = rideDoc.data() as Map<String, dynamic>;
              String rideId = rideDoc.id;

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: ExpansionTile(
                  title: Text("${rideData['pickup']} ➔ ${rideData['drop']}"),
                  subtitle: Text("Seats Available: ${rideData['seats']}"),
                  children: [
                    // Fetch and display requests for this ride
                    StreamBuilder<QuerySnapshot>(
                      stream: _getRideRequests(rideId),
                      builder: (context, requestSnapshot) {
                        if (requestSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!requestSnapshot.hasData || requestSnapshot.data!.docs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("No requests for this ride yet."),
                          );
                        }

                        // Display list of requests
                        return Column(
                          children: requestSnapshot.data!.docs.map((requestDoc) {
                            Map<String, dynamic> requestData =
                                requestDoc.data() as Map<String, dynamic>;
                            String requestId = requestDoc.id;
                            String status = requestData['status'];

                            return ListTile(
                              leading: Icon(Icons.person), // Placeholder for user info
                              title: Text("Requester: ${requestId}"), // User ID shown
                              subtitle: Text("Status: ${status.toUpperCase()}"),
                              trailing: status == "requested"
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.check, color: Colors.green),
                                          onPressed: () => _acceptRequest(rideId, requestId),
                                          tooltip: "Accept Request",
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.red),
                                          onPressed: () => _rejectRequest(rideId, requestId),
                                          tooltip: "Reject Request",
                                        ),
                                      ],
                                    )
                                  : Text(
                                      status == "accepted" ? "✅ Accepted" : "❌ Rejected",
                                      style: TextStyle(
                                        color: status == "accepted" ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
