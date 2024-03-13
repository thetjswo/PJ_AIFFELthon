import 'dart:async'; // Asynchronous programming support in Dart.

import 'package:bson/bson.dart'
    as bson; // Library for BSON (Binary JSON) serialization.
import 'package:flutter/material.dart'; // Flutter framework for building UIs.
import 'package:web_socket_channel/web_socket_channel.dart'; // Library for WebSocket communication.

// Service class for handling real-time data.
class RealtimeDataService {
  // Method to start streaming real-time data.
  StreamController<Map> start() {
    // Connect to WebSocket server.
    var channel =
        WebSocketChannel.connect(Uri.parse("ws://192.168.100.159:5000/ws"));
    // Create a stream controller to manage the data stream.
    var controller = StreamController<Map>();

    // Listen to incoming data from the WebSocket channel.
    channel.stream.listen((event) {
      // Deserialize BSON data received from the WebSocket.
      Map data = bson.BsonCodec.deserialize(bson.BsonBinary.from(event));
      // Add the deserialized data to the stream controller.
      controller.add(data);
    });

    // Return the stream controller.
    return controller;
  }
}

// Model class for real-time data.
class RealtimeDataModel {
  String number;
  RealtimeDataModel({required this.number});
}

// StatefulWidget representing the screen for displaying real-time data.
class DataRouteScreen extends StatefulWidget {
  const DataRouteScreen({Key? key}) : super(key: key);

  @override
  State<DataRouteScreen> createState() => _DataRouteScreenState();
}

// State class for the DataRouteScreen widget.
class _DataRouteScreenState extends State<DataRouteScreen> {
  late StreamController<Map>
      _streamController; // Stream controller for managing data stream.

  @override
  void initState() {
    super.initState();
    // Initialize the stream controller and start streaming real-time data.
    _streamController = RealtimeDataService().start();
  }

  @override
  void dispose() {
    // Close the stream controller when the widget is disposed to prevent memory leaks.
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Realtime Data Demo")), // App bar with a title.
      body: StreamBuilder<Map>(
        // Widget for building UI based on the data stream.
        stream: _streamController
            .stream, // Use the stream from the stream controller.
        builder: (context, snapshot) {
          final number = snapshot.data?["number"] ??
              ""; // Extract "number" data from the snapshot.
          return Container(
            alignment: Alignment.center,
            child: Text(
              number.isNotEmpty
                  ? number
                  : "Connecting", // Display "Connecting" if no data received yet.
              style: const TextStyle(
                  fontSize: 32, color: Colors.blueGrey), // Text style.
            ),
          );
        },
      ),
    );
  }
}

// Entry point of the application.
void main() {
  runApp(const MyApp()); // Run the app by starting the MyApp widget.
}

// StatelessWidget representing the root of the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Realtime Demo', // App title.
      home: DataRouteScreen(), // Set the home screen to DataRouteScreen.
    );
  }
}
