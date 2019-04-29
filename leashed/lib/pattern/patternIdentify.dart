import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:leashed/pattern/blePattern.dart';
import 'package:leashed/scanner.dart';
import 'package:page_transition/page_transition.dart';

class PatternIdentify extends StatelessWidget {
  final List<DateTime> intervalTimes;
  //---General 
  //NOTE: date times and what they mean
  //at index 0: before the detection starts
  //at index ODD: start of detection interval
  //at index EVEN: end of detection interval
  //at index length - 1(will be odd): 

  //---Detailed
  //START-------------------------
  //index 0: START                  (start of wait)   [loop 0]  0
  //FIRST INTERVAL-------------------------
  //index 1: Start of 1st Interval  (end of wait)     [loop 0]
  //index 2: End of 1st Interval    (start of wait)   [loop 1]  1
  //SECOND INTERVAL-------------------------
  //index 3: Start of 2nd Interval  (end of wait)     [loop 1]
  //index 4: End of 2nd Interval    (start of wait)   [loop 2]  2
  //THIRD INTERVAL-------------------------
  //index 5: Start of 3rd Interval  (end of wait)     [loop 2]
  //index 6: End of 3rd Interval    (start of wait)   [before mount 1]
  //END-------------------------
  //index 7: End of Everythign      (end of wait)     [before mount 2]  

  PatternIdentify({
    @required this.intervalTimes,
  });

  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    //basic settings
    double iconSize = 30;
    double paddingLeftRight = 8;
    double maxWidth = MediaQuery.of(context).size.width;
    maxWidth -= iconSize;
    maxWidth -= (paddingLeftRight * 6);

    //fill arrays/maps
    Map<String, PatternAnalyzer> devicesWithPattern = generateMap();
    devicesWithPattern = sortMap(devicesWithPattern);
    List<DevicePattern> potentialSelections = generateWidgets(devicesWithPattern, maxWidth);

    //output UI
    return Scaffold(
      appBar: AppBar(
        title: new Text("Patterns Found"),
      ),
      body: Stack(
        children: <Widget>[
          (potentialSelections.length == 0) ? new NoPatternFound()
          : (potentialSelections.length == 1) ? new OnePatternFound(
            potentialSelections: potentialSelections,
          )
          : new ManyPatternsFound(
            potentialSelections: potentialSelections, 
            paddingLeftRight: paddingLeftRight, 
            iconSize: iconSize,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              child: Column(
                children: <Widget>[
                  (potentialSelections.length == 1)
                  ? Container()
                  : Container(
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

  Map<String, PatternAnalyzer> generateMap(){
    //easy to understand inteval digestion
    DateTime lowerLimit = intervalTimes.first;
    DateTime intStartLeft = intervalTimes[1];
    DateTime intEndLeft = intervalTimes[2];
    DateTime intStartMiddle = intervalTimes[3];
    DateTime intEndMiddle = intervalTimes[4];
    DateTime intStartRight = intervalTimes[5];
    DateTime intEndRight = intervalTimes[6];
    DateTime upperLimit = intervalTimes.last;

    //init return map
    Map<String, PatternAnalyzer> devicesWithPattern = new Map<String, PatternAnalyzer>();

    //iterate through all devices
    List<String> deviceIDs = ScannerStaticVars.allDevicesFound.keys.toList();
    for(int i = 0; i < deviceIDs.length; i++){
      //grab this devices basic data
      String thisDeviceID = deviceIDs[i];
      DeviceData thisDevice = ScannerStaticVars.allDevicesFound[thisDeviceID];
      List<int> thisDeviceRssi = thisDevice.scanData.rssiUpdates;
      List<DateTime> thisDeviceDateTimes = thisDevice.scanData.rssiUpdateDateTimes;
      int scanCountOfDevice = thisDevice.scanData.rssiUpdates.length;

      //init devices analyzer
      PatternAnalyzer analyzerOfDevice = new PatternAnalyzer();

      //iterate through this devices scans
      for(int scan = 0; scan < scanCountOfDevice; scan++){
        DateTime thisScanDateTime = thisDeviceDateTimes[scan];
        //make sure that we only add sections of data that we care to analyze
        if(withinRange(lowerLimit, upperLimit, thisScanDateTime)){

          //determine what interval this scan is in
          Section thisScanSection;
          if(withinRange(intStartLeft, intEndLeft, thisScanDateTime)){
            thisScanSection = Section.left;
          }
          else if(withinRange(intStartMiddle, intEndMiddle, thisScanDateTime)){
            thisScanSection = Section.middle;
          }
          else if(withinRange(intStartRight, intEndRight, thisScanDateTime)){
            thisScanSection = Section.right;
          }
          else thisScanSection = Section.neither;

          //add this to the data we are analyzing
          int thisScanRssi = thisDeviceRssi[scan];
          analyzerOfDevice.add(thisScanRssi, thisScanDateTime, thisScanSection);
        }
      }

      //determine if this devices signals match our expected pattern
      //---1 must have data in all 3 sections
      bool hasLeft = analyzerOfDevice.left.hasItems();
      bool hasMiddle = analyzerOfDevice.middle.hasItems();
      bool hasRight = analyzerOfDevice.right.hasItems();
      if(hasLeft && hasMiddle && hasRight){
        //---2 middle average must be higher than left and right average
        double leftAvg = analyzerOfDevice.left.average;
        double midAvg = analyzerOfDevice.middle.average;
        double rightAvg = analyzerOfDevice.right.average;
        if(midAvg > leftAvg && midAvg > rightAvg){
          devicesWithPattern[thisDeviceID] = analyzerOfDevice;
        }
      }
    }

    //return result
    return devicesWithPattern;
  }

  Map<String, PatternAnalyzer> sortMap(Map<String, PatternAnalyzer> map){
    return map;
  }

  List<DevicePattern> generateWidgets(Map<String, PatternAnalyzer> map, double maxWidth){
    //init the arrray
    List<DevicePattern> widgets = new List<DevicePattern>();

    //fill the array
    if(map.length != 0){
      List<String> devicesIDs = map.keys.toList();
      for(int i = 0; i < devicesIDs.length; i++){
        String thisDeviceID = devicesIDs[i];
        DeviceData thisDevice  = ScannerStaticVars.allDevicesFound[thisDeviceID];
        String thisDeviceName = thisDevice.name;
        String thisDeviceType = shortBDT(thisDevice.type);
        widgets.add(
          new DevicePattern(
            name: (thisDeviceName == "") ? "N0 NAME" : thisDeviceName,
            id: thisDeviceID,
            type: thisDeviceType,
            maxWidth: maxWidth,
            minRssi: map[thisDeviceID].rssiMin,
            maxRssi: map[thisDeviceID].rssiMax,
            intervalTimes: intervalTimes,
            /*
            dtToRssi: new Map<DateTime,int>(),
            dtToIdealRssi: new Map<DateTime,int>(),
            */
          ),
        );
      }
    }

    //return the array
    return widgets;
    
    /*
    return [new DevicePattern(
      name: "Tile Tracker",
      id: "12:4A:8B:87:23:8A",
      type: "Low Energy",
      maxWidth: maxWidth,
      minRssi: 2,
      maxRssi: 9,
      intervalTimes: new List<DateTime>(),
      dtToRssi: new Map<DateTime,int>(),
      dtToIdealRssi: new Map<DateTime,int>(),
    )];
    */
  }
}

class ManyPatternsFound extends StatelessWidget {
  const ManyPatternsFound({
    Key key,
    @required this.potentialSelections,
    @required this.paddingLeftRight,
    @required this.iconSize,
  }) : super(key: key);

  final List<DevicePattern> potentialSelections;
  final double paddingLeftRight;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return new Swiper(
      loop: false,
      itemBuilder: (BuildContext context,int index){
        return potentialSelections[index];
      },
      itemCount: potentialSelections.length,
      control: new SwiperControl(
        padding: EdgeInsets.only(
          top: 85, 
          right: paddingLeftRight, 
          left: paddingLeftRight,
        ),
        size: iconSize,
      ),
      //NOTE: no pagination we might have alot of pages (25+)
    );
  }
}

class OnePatternFound extends StatelessWidget {
  const OnePatternFound({
    Key key,
    @required this.potentialSelections,
  }) : super(key: key);

  final List<DevicePattern> potentialSelections;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: potentialSelections[0],
    );
  }
}

class NoPatternFound extends StatelessWidget {
  const NoPatternFound({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            color: Navigation.blueGrey,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("The Signal Pattern"),
              new Text("Was Not Found"),
              new Text("Please Try Again"),
              new Text(""),
              new Text(""),
            ],
          ),
        ),
      ),
    );
  }
}

class DevicePattern extends StatelessWidget {
  DevicePattern({
    Key key,
    @required this.name,
    this.id,
    this.type,
    @required this.maxWidth,
    this.minRssi,
    this.maxRssi,
    //wait 0->1 | 2->3 | 4->5 | 6->7
    //intervals 1->2 | 3->4 | 5->6
    this.intervalTimes,
    this.dtToRssi,
    this.dtToIdealRssi,
  }) : super(key: key);

  //basic device info
  final String name;
  final String id;
  final String type;
  //avoid any device data being over arrows
  final double maxWidth;
  //limit y axis on graph
  final int minRssi;
  final int maxRssi;
  //highlight times between takes with black
  //AND limits x axis on graph
  final List<DateTime> intervalTimes;
  //points
  final Map<DateTime, int> dtToRssi;
  //ideal points
  final Map<DateTime, int> dtToIdealRssi;

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
                        id + " | " + type,
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