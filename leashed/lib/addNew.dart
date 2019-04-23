import 'package:flutter/material.dart';

class AddNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Add New Device"),
      ),
      body: new Center(
        child: Container(
          child: new Text("Add New Device"),
        ),
      ),
    );
  }
}