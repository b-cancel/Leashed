import 'package:flutter/material.dart';
import 'package:leashed/navigation.dart';

class PatternIdentify extends StatelessWidget {
  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Patterns Found"),
      ),
      body: PageView(
        controller: controller,
        children: <Widget>[
          new DevicePattern(
            name: "Tile Tracker",
          ),
          new DevicePattern(
            name: "XY Tracker",
          ),
          new DevicePattern(
            name: "Unknown",
          ),
        ],
      ),
    );
  }
}

class DevicePattern extends StatelessWidget {
  const DevicePattern({
    Key key,
    @required this.name,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width * .75;

    return new Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              color: Colors.blue,
              height: height,
              width: width,
              child: new Center(
                child: new Text("Graph Here"),
              ),
            ),
            Positioned.fill(
              child: Container(
                alignment: Alignment.topLeft,
                child: new Text("Legend Here"),
              ),
            )
          ],
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: new Text(
                    name,
                    style: TextStyle(
                      color: Navigation.blueGrey,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: new Text(
                    "Device ID | Device Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RaisedButton(
                  color: Navigation.blueGrey,
                  onPressed: () => print("selecting this device"),
                  child: new Text(
                    "Select This Device",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: new Text("Swipe To Manually Identify The Pattern"),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: RaisedButton(
                      onPressed: () => print("try again"),
                      child: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Icon(Icons.refresh),
                          new Text(" Try Again"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}