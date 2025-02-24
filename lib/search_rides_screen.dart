import 'package:flutter/material.dart'; // Flutter's UI toolkit
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for querying rides
import 'package:intl/intl.dart';
import 'package:kidschaupalcarpool/ride_details_screen.dart'; // For date formatting

class SearchRidesScreen extends StatefulWidget {
  @override
  _SearchRidesScreenState createState() => _SearchRidesScreenState();
}

class _SearchRidesScreenState extends State<SearchRidesScreen> {
  // Controllers for user input fields
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();

  DateTime? selectedDate; // Stores the date selected by the user
  List<QueryDocumentSnapshot> matchedRides = []; // List to hold matched rides from Firestore
  bool isLoading = false; // Controls the loading spinner visibility

  // Function to let user pick a travel date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Function to search for rides based on user input
  Future<void> _searchRides() async {
    if (pickupController.text.trim().isEmpty ||
        dropController.text.trim().isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields before searching.")),
      );
      return;
    }

    setState(() {
      isLoading = true; // Show loading spinner while querying
    });

    try {
      // Query Firestore for rides matching the user criteria
      QuerySnapshot ridesSnapshot = await FirebaseFirestore.instance
          .collection("rides")
          .where("pickup", isEqualTo: pickupController.text.trim())
          .where("drop", isEqualTo: dropController.text.trim())
          .where("departureDate", isEqualTo: selectedDate!.toIso8601String())
          .get();

      setState(() {
        matchedRides = ridesSnapshot.docs; // Store the matched rides
        isLoading = false; // Hide loading spinner after search
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error searching for rides: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search for Rides")), // App bar title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🚏 Input for Pickup Location
            TextField(
              controller: pickupController,
              decoration: InputDecoration(
                labelText: "Pickup Location",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Input for Drop Location
            TextField(
              controller: dropController,
              decoration: InputDecoration(
                labelText: "Drop Location",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Button to select travel date
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickDate(context),
                    child: Text(selectedDate == null
                        ? "Pick Travel Date"
                        : "Date: ${DateFormat('dd-MM-yyyy').format(selectedDate!)}"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Search Button
            ElevatedButton(
              onPressed: _searchRides,
              child: Text("Search Rides"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
            ),
            SizedBox(height: 20),

            // Show loading spinner while searching
            if (isLoading)
              CircularProgressIndicator(),

            // Show matched rides if any
            if (!isLoading && matchedRides.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: matchedRides.length,
                  itemBuilder: (context, index) {
                    final ride = matchedRides[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text("${ride['pickup']} ➔ ${ride['drop']}"),
                        subtitle: Text(
                          "Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(ride['departureDate']))}\n"
                          "Time: ${ride['departureTime']}\n"
                          "Seats: ${ride['seats']} available\n"
                          "Price: ₹${ride['pricePerSeat']} per seat",
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideDetailsScreen(rideId: matchedRides[index].id), // 🔗 Passing ride ID
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

            // If no matches found
            if (!isLoading && matchedRides.isEmpty && selectedDate != null)
              Text("No rides found for the selected criteria."),
          ],
        ),
      ),
    );
  }
}
