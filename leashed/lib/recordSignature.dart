import 'package:flutter/material.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/scanner.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:leashed/scannerUI.dart';

//TODO...

//for both(rssi and slope)
//0. domain selector (seconds) -> determines what points we dont read for our graph
//1. domain selectors tells us how many points we are using VS how many points there are
//1. show range... min, max, range (overall)
//2. show range... min, max, range (within our selected domain)
//3. functional rolling value selector
//4. pulsing container as tall as each graph that indicates a new measurement came in (Since we cant have a pulsating graph)
//5. a solid size spacer before the pusling container

//slope graph
//1. get slope between all points in rolling average curve (given the rolling average values from the rssi graph ofcourse) (double)
//2. the same as above but (integer)

//for both
//1. given the last rssi value... highlight areas above and below it + and - [set of positive numbers]
//2. IF possible... use black with an opacity so that only the inner most range is actually black... the rest naturally creat a gradient

//NOTE: we know for a fact that when we arrive at this widget our bluetooth is on

class LiveScanner extends StatefulWidget {
  final String deviceID;

  LiveScanner({
    this.deviceID,
  });

  @override
  _LiveScannerState createState() => _LiveScannerState();
}

class _LiveScannerState extends State<LiveScanner> {

  @override
  void initState() {
    //allows live updating scanner
    ScannerStaticVars.allDevicesFound[widget.deviceID].scanData.rssiUpdateCount.addListener(customSetState);
    super.initState();
  }

  @override
  void dispose() { 
    //allow live updating scanner
    ScannerStaticVars.allDevicesFound[widget.deviceID].scanData.rssiUpdateCount.removeListener(customSetState);
    super.dispose();
  }

  customSetState() async {
    if(mounted){
      setState((){});
    }
  }

  final TextEditingController rollingAverageValue = new TextEditingController(text: "3");

  @override
  Widget build(BuildContext context) {
    /*
    double heightDiv3 = MediaQuery.of(context).size.height / 3;

    List<common.AnnotationSegment> annotations = new List<common.AnnotationSegment>();
    annotations.addAll(highlightErrorRanges([1,2,3,4]),
    */
    ScanData scanData = ScannerStaticVars.allDevicesFound[widget.deviceID].scanData;
    int rollingAverage = (rollingAverageValue.text == "") ? 0 : int.parse(rollingAverageValue.text);
    int sampleCount = scanData.rssiUpdateCount.value;


    //domain
    int minDateTime = dateTimeToInt(scanData.rssiUpdateDateTimes[0]); //TODO... make this only show you 30 seconds after max
    int maxDateTime = dateTimeToInt(scanData.rssiUpdateDateTimes.last);
    List<int> dateTimes = listDateTimeToListInt(scanData.rssiUpdateDateTimes);

    //range
    List<int> scanRSSIs = scanData.rssiUpdates;
    int minRSSI;
    int maxRSSI;

    //find the min and max RSSI within the current min, max date time range
    //TODO... we can improve this massively with some simple dynamic memoization
    for(int i = 0; i < scanRSSIs.length; i++){
      int thisRSSI = scanRSSIs[i];
      int thisDateTime = dateTimes[i];
      if(minDateTime <= thisDateTime && thisDateTime <= maxDateTime){
        if(minRSSI == null) minRSSI = thisRSSI;
        else minRSSI = (thisRSSI < minRSSI) ? thisRSSI : minRSSI;

        if(maxRSSI == null) maxRSSI = thisRSSI;
        else maxRSSI = (maxRSSI < thisRSSI) ? thisRSSI : maxRSSI;
      }
    }

    //cal stuff for pulse
    //NOTE: we use min so the scanner being off doesn't throw off what should be our average
    Duration minDuration = scanData.minIntervalDuration ?? Duration(milliseconds: 100);
    Duration averageInterval = minDuration * 3; //assumed average make things simpler

    DateTime lastScan = scanData.rssiUpdateDateTimes.last;

    return Row(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: charts.LineChart(
                  createCharts(
                    dateTimes,
                    scanRSSIs,
                    [3, 7],
                    [
                      charts.MaterialPalette.blue.shadeDefault,
                      charts.MaterialPalette.pink.shadeDefault,
                    ],
                    [7, 3],
                  ),
                  animate: false,
                  layoutConfig: charts.LayoutConfig(
                    topMarginSpec: charts.MarginSpec.fixedPixel(0),
                    rightMarginSpec: charts.MarginSpec.fixedPixel(0),
                    bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
                    leftMarginSpec: charts.MarginSpec.fixedPixel(0),
                  ),
                  defaultRenderer: new charts.LineRendererConfig(
                    roundEndCaps: false, //makes patterns more clear 
                    includePoints: false, //makes patterns more clear
                  ),
                  domainAxis: new charts.NumericAxisSpec(
                    showAxisLine: false,
                    viewport: new charts.NumericExtents(
                      minDateTime, 
                      maxDateTime,
                    ),
                    renderSpec: new charts.NoneRenderSpec(),
                  ),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                    showAxisLine: false,
                    viewport: new charts.NumericExtents(
                      minRSSI,
                      maxRSSI,
                    ),
                    renderSpec: new charts.NoneRenderSpec(),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: WhiteCircle(
                  value: rssiToAdjustedRssi(maxRSSI).toString(),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: WhiteCircle(
                  value: rssiToAdjustedRssi(minRSSI).toString(),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: WhiteCircle(
                  value: scanRSSIs.length.toString(),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          color: Colors.white,
          width: 25,
          child: NewSignalPulse(
            scanData: ScannerStaticVars.allDevicesFound[widget.deviceID].scanData,
            interval: Duration(milliseconds: 100),
          ),  
        ),
      ],
    );
  }
}

class NewSignalPulse extends StatefulWidget {
  final ScanData scanData;
  final Duration interval;

  NewSignalPulse({
    @required this.scanData,
    this.interval: const Duration(milliseconds: 250),
  });

  @override
  _NewSignalPulseState createState() => _NewSignalPulseState();
}

class _NewSignalPulseState extends State<NewSignalPulse> {
  void update() async{
    await Future.delayed(widget.interval);
    if(mounted){
      setState(() {});
      update();
    }
  }

  @override
  void initState() {
    update(); //start cyclical update
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //NOTE: we use min so the scanner being off doesn't throw off what should be our average
    Duration minDuration = widget.scanData.averageIntervalDuration ?? Duration(milliseconds: 100);
    Duration averageInterval = minDuration;
    averageInterval = (averageInterval == null) ? Duration(seconds: 1) : averageInterval;

    DateTime lastScan = widget.scanData.rssiUpdateDateTimes.last;
    Duration intervalSoFar = (DateTime.now()).difference(lastScan);

    //0 -> averageInterval
    //0 -> 1
    int intervalLeftTill0 = averageInterval.inMicroseconds - intervalSoFar.inMicroseconds;
    double float = intervalLeftTill0 / averageInterval.inMicroseconds;
    print("average: " + averageInterval.toString() + " so far " + intervalSoFar.toString());
    print("sub " + intervalLeftTill0.toString() + " avg " + averageInterval.inMilliseconds.toString());

    //float affect size
    double barWidth;
    barWidth = lerp(0, 25, float);

    //print("width: " + barWidth.toString());

    return Container(
      width: barWidth,
      color: Colors.pink,
    );
  }
}