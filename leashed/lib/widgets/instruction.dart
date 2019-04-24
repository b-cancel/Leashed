import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/navigation.dart';

class Instruction extends StatelessWidget {
  final Map<String, DeviceData> allDevicesFound;
  final List<DateTime> scanDateTimes;
  final String imageUrl;
  final List<String> lines;
  final Function onDone;

  Instruction({
    @required this.allDevicesFound,
    @required this.scanDateTimes,
    @required this.imageUrl,
    @required this.lines,
    @required this.onDone,
  });
  
  @override
  Widget build(BuildContext context) {
    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    
    //get size
    double imageSize = MediaQuery.of(context).size.width;
    double titleHeight = (MediaQuery.of(context).size.height - imageSize) / 2;

    //create list of text widgets
    List<Widget> textLines = new List<Widget>();
    for(int i = 0; i < lines.length; i++){
      textLines.add(new Text(lines[i]));
    }

    //return widget
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: new Text("Pattern Recognition"),
        ),
        body: new Column(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: titleHeight,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Navigation.blueGrey,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: textLines,
                ),
              ),
            ),
            Container(
              height: imageSize,
              width: imageSize,
              child: Image.asset(imageUrl),
            ),
            Expanded(
              child: Center(
                child: new RaisedButton(
                  color: Navigation.blueGrey,
                  onPressed: () => onDone(),
                  child: new Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}