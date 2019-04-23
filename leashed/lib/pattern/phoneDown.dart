import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/navigation.dart';
import 'package:gif_ani/gif_ani.dart';

class PhoneDown extends StatefulWidget {
  @override
  _PhoneDownState createState() => _PhoneDownState();
}

class _PhoneDownState extends State<PhoneDown> with SingleTickerProviderStateMixin{
  GifController _animationCtrl;

  @override
  void initState() {
    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    //init state
    super.initState();

    //gif
    _animationCtrl = new GifController(
      vsync: this,
      duration: new Duration(milliseconds: 5000),
      frameCount: 13,
    );

    _animationCtrl.runAni();
  }

  @override
  void dispose() {
    _animationCtrl.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
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
            Container(
              height: imageSize,
              width: imageSize,
              color: Colors.red,
              child: new GifAnimation(
                image: new AssetImage(
                  "assets/gifs/final/phoneOnTable.gif",
                ),
                controller: _animationCtrl,
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