import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quikle_rider/core/services/network/webscoket_services.dart';
import 'package:quikle_rider/features/profile/presentation/screen/practice/rider_websocket.dart';

class SocketUIScreen extends StatefulWidget {
  const SocketUIScreen({super.key});

  @override
  State<SocketUIScreen> createState() => _SocketUIScreenState();
}

class _SocketUIScreenState extends State<SocketUIScreen> {
  static const int _demoRiderId = 342;

  late final WebSocketService _service;
  StreamSubscription<bool>? _connectionSubscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _service = WebSocketService();
    _connectionSubscription = _service.connectionChanges.listen((connected) {
      if (!mounted) return;
      setState(() {
        _isConnected = connected;
      });
    });
    _service.connect(_demoRiderId);
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _service.dispose();

    super.dispose();
  }

  void _toggleConnection() {
    if (_isConnected) {
      _service.disconnect();
    } else {
      _service.connect(_demoRiderId);
    }
  }

  void _sendSampleLocation() {
    _service.sendLocation(46, 36);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebSocket JSON Test")),
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isConnected ? _sendSampleLocation : null,
                  child: const Text("send"),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _toggleConnection,
                  child: Text(_isConnected ? "Disconnect" : "Connect"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _isConnected
                    ? "Status: Connected (rider $_demoRiderId)"
                    : "Status: Disconnected",
                style: TextStyle(
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            Expanded(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: _service.locationStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Waiting for WebSocket response...");
                  }

                  final data = snapshot.data!;
                  final latitude = data['lat'];
                  final longitude = data['lng'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Latitude: $latitude"),
                      Text("Longitude: $longitude"),

                      const SizedBox(height: 20),
                      const Text(
                        "Raw JSON Response:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(data.toString()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
