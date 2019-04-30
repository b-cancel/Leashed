import 'package:flutter/material.dart';
import 'package:leashed/addNew.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:leashed/pattern/blePattern.dart';
import 'package:leashed/pattern/patternChart.dart';
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
    List<String> sortedDevices = sortMap(devicesWithPattern);
    List<DevicePattern> potentialSelections = generateWidgets(
      sortedDevices, 
      devicesWithPattern, 
      maxWidth,
    );

    //output UI
    return Scaffold(
      appBar: AppBar(
        title: new Text(sortedDevices.length.toString() 
        +  " Matching Signal Pattern"
        + ((sortedDevices.length == 1) ? "" : "s")),
      ),
      body: Stack(
        children: <Widget>[
          (potentialSelections.length == 0) ? new NoPatternFound()
          : Stack(
            children: <Widget>[
              (potentialSelections.length == 1)
              ? new OnePatternFound(
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
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.topLeft,
                    child: new Column(
                      children: <Widget>[
                        new LegendColorDescription(
                          color: Colors.blue,
                          text: "Observed",
                        ),
                        Container(
                          height: 8,
                        ),
                        new LegendColorDescription(
                          color: Colors.black,
                          text: "Expected",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                      Navigation.timeToDetectPattern.value += Navigation.addToTimeToDetectPattern.value;

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
        //NOTE: we use ints so some difference is visible
        int leftAvg = analyzerOfDevice.left.average.toInt();
        int midAvg = analyzerOfDevice.middle.average.toInt();
        int rightAvg = analyzerOfDevice.right.average.toInt();
        if(midAvg > leftAvg && midAvg > rightAvg){
          devicesWithPattern[thisDeviceID] = analyzerOfDevice;
        }
      }
    }

    //return result
    return devicesWithPattern;
  }

  List<String> sortMap(Map<String, PatternAnalyzer> map){
    Map<String, DeviceData> allDevicesFound = ScannerStaticVars.allDevicesFound;
    List<String> deviceIDsFromMap = map.keys.toList();

    //-------------------------sort by rssi average during entire interval
    //grab all signal averages (of whatever devices are in the map)
    List<double> rssiAverages = new List<double>();
    for(int i = 0; i < map.length; i++){
      String deviceID = deviceIDsFromMap[i];
      rssiAverages.add(map[deviceID].total.average);
    }
    
    //sort device averages
    List<double> sortedRssiAverage = new List<double>();
    sortedRssiAverage.addAll(rssiAverages);
    sortedRssiAverage.sort();

    //order the devices IDs as averages
    List<String> sortedDeviceIDs = new List<String>();
    for(int i = 0; i < sortedRssiAverage.length; i++){
      double thisAverage = sortedRssiAverage[i];

      //search for all the IDs that have this sorted Rssi Average
      //NOTE: highly unlikely but we have to cover the edge case
      List<String> devicesWithThisAverage = new List<String>();
      for(int i = 0; i < deviceIDsFromMap.length; i++){
        String deviceID = deviceIDsFromMap[i];
        if(map[deviceID].total.average == thisAverage){
          devicesWithThisAverage.add(deviceID);
        }
      }

      //loop all the IDs that have this sorted Rssi Average
      //NOTE: so we have one device for every sorted average place in the sortedDeviceIDs array
      for(int i = 0; i < devicesWithThisAverage.length; i++){
        String deviceID = devicesWithThisAverage[i];
        if(sortedDeviceIDs.contains(deviceID) == false){
          sortedDeviceIDs.add(deviceID);
          break;
        }
      }
    }

    //use the sorted device IDs for the next step
    deviceIDsFromMap = sortedDeviceIDs;

    //-------------------------sort by with and without name
    List<String> withName = new List<String>();
    List<String> withoutName = new List<String>();
    
    //add the devices in the map to each respective list
    for(int i = 0; i < deviceIDsFromMap.length; i++){
      String deviceID = deviceIDsFromMap[i];
      if(allDevicesFound[deviceID].name != ""){
        withName.add(deviceID);
      }
      else withoutName.add(deviceID);
    }

    //TODO... sort the withName by the devices name NOT it's id
    return ([]..addAll(withName))..addAll(withoutName);
  }

  List<DevicePattern> generateWidgets(
    List<String> sortedDevices, 
    Map<String, PatternAnalyzer> map, 
    double maxWidth,
    ){
    //init the arrray
    List<DevicePattern> widgets = new List<DevicePattern>();

    //fill the array
    if(map.length != 0){
      for(int i = 0; i < sortedDevices.length; i++){
        String thisDeviceID = sortedDevices[i];
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
            averageLeft: map[thisDeviceID].left.average,
            averageMiddle: map[thisDeviceID].middle.average,
            averageRight: map[thisDeviceID].right.average,
            intervalTimes: intervalTimes,
            rssis: map[thisDeviceID].rssi,
            dateTimes: map[thisDeviceID].dateTimes,
          ),
        );
      }
    }

    //return the array
    return widgets;
  }
}

class LegendColorDescription extends StatelessWidget {
  const LegendColorDescription({
    @required this.color,
    @required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Container(
          color: color,
          height: 18,
          width: 18,
        ),
        new Text(" " + text),
      ],
    );
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
              new Text("A Matching Signal Pattern"),
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
    @required this.id,
    @required this.type,
    @required this.maxWidth,
    @required this.minRssi,
    @required this.maxRssi,
    @required this.averageLeft,
    @required this.averageMiddle,
    @required this.averageRight,
    //wait 0->1 | 2->3 | 4->5 | 6->7
    //intervals 1->2 | 3->4 | 5->6
    @required this.intervalTimes,
    @required this.rssis,
    @required this.dateTimes,
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
  final double averageLeft;
  final double averageMiddle;
  final double averageRight;
  //highlight times between takes with black
  //AND limits x axis on graph
  final List<DateTime> intervalTimes;
  //points
  final List<int> rssis;
  final List<DateTime> dateTimes;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width * .75;

    return Container(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: height,
            width: width,
            child: new Center(
              child: Chart(
                scanDateTimes: dateTimes,
                scanRSSIs: rssis,
                minRSSI: minRssi,
                maxRSSI: maxRssi,
                averageLeft: averageLeft.toInt(),
                averageMiddle: averageMiddle.toInt(),
                averageRight: averageRight.toInt(),
                intervalDateTimes: intervalTimes,
              ),
            ),
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
                        Navigation.timeToDetectPattern.value = Navigation.defaultTimeToDetectPattern.value; //RESET
                        Navigator.pushReplacement(context, PageTransition(
                          type: PageTransitionType.fade,
                          duration: Duration.zero, 
                          child: AddNew(
                            name: name,
                            id: id,
                            type: type,
                          ),
                        ));
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