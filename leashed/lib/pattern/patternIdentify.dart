import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:leashed/navigation.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:leashed/pattern/blePattern.dart';
import 'package:page_transition/page_transition.dart';

class PatternIdentify extends StatelessWidget {
  final controller = PageController();

  @override
  Widget build(BuildContext context) {

    double iconSize = 30;
    double paddingLeftRight = 8;
    double maxWidth = MediaQuery.of(context).size.width;
    maxWidth -= iconSize;
    maxWidth -= (paddingLeftRight * 6);

    List<DevicePattern> options = [
      new DevicePattern(
        maxWidth: maxWidth,
        name: "Tile Tracker",
      ),
      new DevicePattern(
        maxWidth: maxWidth,
        name: "XY Tracker",
      ),
      new DevicePattern(
        maxWidth: maxWidth,
        name: "Unknown",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: new Text("Patterns Found"),
      ),
      body: Stack(
        children: <Widget>[
          new Swiper(
            loop: false,
            itemBuilder: (BuildContext context,int index){
              return options[index];
            },
            itemCount: options.length,
            control: new SwiperControl(
              padding: EdgeInsets.only(
                top: 85, 
                right: paddingLeftRight, 
                left: paddingLeftRight,
              ),
              size: iconSize,
            ),
            //NOTE: no pagination we might have alot of pages (25+)
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(4),
                    child: new Text("Swipe To Manually Identify The Pattern"),
                  ),
                  Container(
                  padding: EdgeInsets.all(8),
                  child: RaisedButton(
                    onPressed: (){
                      //change how long you are waiting for pattern detection
                      Navigation.timeToDetectPattern.value += 1;

                      //try again but waiting a little longer
                      Navigator.pushReplacement(context, PageTransition(
                        type: PageTransitionType.fade,
                        duration: Duration.zero, 
                        child: BlePattern(
                          secondsPerStep: Navigation.timeToDetectPattern.value,
                        ),
                      ));
                    },
                    child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Icon(Icons.refresh),
                        new Text(" Try Again"),
                      ],
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

class DevicePattern extends StatelessWidget {
  const DevicePattern({
    Key key,
    @required this.name,
    @required this.maxWidth,
  }) : super(key: key);

  final String name;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width * .75;

    return Container(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
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
          Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              child: Container(
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
                      onPressed: (){
                        Navigator.of(context).pop();
                        Navigation.timeToDetectPattern.value = 3; //RESET
                      },
                      child: new Text(
                        "Select This Device",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}