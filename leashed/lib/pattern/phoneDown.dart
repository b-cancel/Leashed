import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/navigation.dart';

class PhoneDown extends StatefulWidget{
  @override
  _PhoneDownState createState() => _PhoneDownState();
}

class _PhoneDownState extends State<PhoneDown> {
  int imageInt;

  @override
  void initState() {
    imageInt = 1;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    //alternate between both of the exact same gifs so we can restart the gif at will
    imageInt = (imageInt == 1) ? 2 : 1;
    
    //get size
    double imageSize = MediaQuery.of(context).size.width;
    double titleHeight = (MediaQuery.of(context).size.height - imageSize) / 2;

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
            Container(
              height: titleHeight,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Navigation.blueGrey,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text("Place Your Phone"),
                    new Text("On A Flat Surface"),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  
                });
              },
              child: Container(
                height: imageSize,
                width: imageSize,
                child: Image.asset(
                  "assets/gifs/final/phoneOnTable/phoneOnTable$imageInt.gif"
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: new RaisedButton(
                  color: Navigation.blueGrey,
                  onPressed: (){
                    print("on pressed");
                  },
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