import 'package:flutter/material.dart'; // Flutter framework for UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // For storing ride data in Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // For getting the current user ID
import 'my_rides_screen.dart'; // After offering a ride, we will redirect users here

class OfferRideScreen extends StatefulWidget {
  @override
  _OfferRideScreenState createState() => _OfferRideScreenState(); // State management for the screen
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  // Controllers to get user input from text fields
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();
  final TextEditingController seatsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // Variables to store selected date and time
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final _formKey = GlobalKey<FormState>(); // Key to validate the form

  // Function to pick a date from a date picker dialog
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date is current date
      firstDate: DateTime.now(), // User cannot select past dates
      lastDate: DateTime(2100), // Allowing future dates
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate; // Update the selected date
      });
    }
  }

  // Function to pick time from a time picker dialog
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Default time is current time
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime; // Update the selected time
      });
    }
  }

  // Function to save ride details to Firestore
  Future<void> _offerRide() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select both date and time for your ride")),
        );
        return;
      }

      try {
        User? user = FirebaseAuth.instance.currentUser; // Get current user
        if (user != null) {
          await FirebaseFirestore.instance.collection("rides").add({
            "userId": user.uid,
            "pickup": pickupController.text.trim(),
            "drop": dropController.text.trim(),
            "seats": int.parse(seatsController.text.trim()),
            "pricePerSeat": priceController.text.isEmpty
                ? 0
                : double.parse(priceController.text.trim()),
            "departureDate": selectedDate!.toIso8601String(),
            "departureTime": selectedTime!.format(context),
            "createdAt": Timestamp.now(), // Timestamp for ride creation
          });

          // Redirect user to the screen showing their rides after successfully offering a ride
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyRidesScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to offer ride: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Offer a Ride")), // App bar title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign form key for validation
          child: ListView(
            children: [
              TextFormField(
                controller: pickupController,
                decoration: InputDecoration(labelText: "Pickup Location"),
                validator: (value) => value!.isEmpty ? "Enter pickup location" : null,
              ),
              TextFormField(
                controller: dropController,
                decoration: InputDecoration(labelText: "Drop Location"),
                validator: (value) => value!.isEmpty ? "Enter drop location" : null,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate(context),
                      child: Text(selectedDate == null
                          ? "Pick Date"
                          : "Date: ${selectedDate!.toLocal()}".split(' ')[0]),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickTime(context),
                      child: Text(selectedTime == null
                          ? "Pick Time"
                          : "Time: ${selectedTime!.format(context)}"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Available Seats"),
                validator: (value) => value!.isEmpty ? "Enter available seats" : null,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price per Seat (optional)",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _offerRide,
                child: Text("Offer Ride"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
