import 'package:flutter/material.dart';

class DeviceMap extends StatelessWidget {
  final String image;
  final String name;
  final String status;

  DeviceMap({
    this.image,
    this.name,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          child: Text("center"),
        ),
      ),
    );
  }
}