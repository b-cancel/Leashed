import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/manualLib/flutter_xlider.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';

import 'dart:math' as math;

import 'package:leashed/sliverModifications/sliverPersistentHeader.dart' as sliverPersistentHeader;
import 'package:leashed/sliverModifications/flexibleSpaceBar.dart' as flexibleSpaceBar;
import 'package:leashed/widgets/bluetoothOffBanner.dart';

class EntireSlider extends StatefulWidget {
  const EntireSlider({
    Key key,
  }) : super(key: key);

  @override
  _EntireSliderState createState() => _EntireSliderState();
}

class _EntireSliderState extends State<EntireSlider> {
  final ValueNotifier<int> sliderValue = new ValueNotifier<int>(1);

  @override
  void initState() {
    sliderValue.addListener(reactToSliderChange);
    super.initState();
  }

  @override
  void dispose() { 
    sliderValue.removeListener(reactToSliderChange);
    super.dispose();
  }

  reactToSliderChange(){
    print("CHANGED TO ->");
    switch(sliderValue.value){
      case 0: warning(); break;
      case 1: print("1"); break;
      case 2: print("2"); break;
      default: print("3"); break;
    }
  }

  warning(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark(),
          child: Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16),
                  color: Colors.black,
                  child: Text(
                    'S.O.S Mode',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                Container(
                  color: Navigation.blueGrey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(16),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("If ANY Device Disconnects"),
                              Text("A Timer Will Begin"),
                              Text("If Don't Check In"),
                              Text(""),
                              Text("Your Emergency Contacts"),
                              Text("Will Be Alerted"),
                            ],
                          ),
                        )
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                              child: Text('Disable'),
                              onPressed: () {
                                sliderValue.value = 1; //Red Mode
                                setState((){}); //make the slider change
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: Text('Enable'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //all the things that affect the travel of the tick
    double tickWidth = 30; //total
    double whitePaddingLR = 16; //per side
    double paddingWithinSlider = 8; //per side
    double tickTravel = MediaQuery.of(context).size.width; //total

    //calculate where to place the tick
    tickTravel -= (whitePaddingLR * 2);
    tickTravel -= (paddingWithinSlider * 2);
    tickTravel -= tickWidth;
    double tickPadding = sliderValue.value * (tickTravel / 3);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(whitePaddingLR, 0, whitePaddingLR, 0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: new SliderBackground(
              height: 24,
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.fromLTRB(paddingWithinSlider, 0, paddingWithinSlider, 0),
              child: Stack(
                children: <Widget>[
                  Opacity(
                    opacity: 0,
                    child: Slider(
                      onChanged: (newValue) {
                        setState(() => sliderValue.value = newValue.toInt());
                      },
                      value: sliderValue.value.toDouble(),
                      min: 0,
                      max: 3,
                      divisions: 3,
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        padding: EdgeInsets.only(left: tickPadding),
                        alignment: Alignment.centerLeft,
                        child: Tick(
                          width: tickWidth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Tick extends StatelessWidget {
  final double width;
  const Tick({
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width - (1* 2), //1 pixel border on 2 sides
      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
      decoration: new BoxDecoration(
        color: Navigation.blueGrey,
        borderRadius: BorderRadius.circular(10),
        border: new Border.all(
          color: Colors.white,
        ),
      ),
      child: Icon(
        Icons.menu,
        color: Colors.white,
      ),
    );
  }
}

class SliderBackground extends StatelessWidget {
  final double height;

  const SliderBackground({
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.toDouble(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new ColorSegment(
              color: Colors.black,
            ),
            new GradientSegment(
              left: Colors.black,
              right: Colors.red,
            ),
            new ColorSegment(
              color: Colors.red,
            ),
            new GradientSegment(
              left: Colors.red,
              right: Colors.yellow,
            ),
            new ColorSegment(
              color: Colors.yellow,
            ),
            new GradientSegment(
              left: Colors.yellow,
              right: Colors.green,
            ),
            new ColorSegment(
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class ColorSegment extends StatelessWidget {
  final Color color;

  const ColorSegment({
    this.color,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
      )
    );
  }
}

class GradientSegment extends StatelessWidget {
  final Color left;
  final Color right;

  const GradientSegment({
    this.left,
    this.right,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [left, right], // whitish to gray
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
      ),
    );
  }
}