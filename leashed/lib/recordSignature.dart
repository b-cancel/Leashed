import 'package:charts_common/common.dart';
import 'package:flutter/material.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(16),
          child: Text("Samlpe Count: " + sampleCount.toString()),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: TextFormField(
            controller: rollingAverageValue,
            decoration: InputDecoration(
              prefix: new Text("Rolling Value: ")
            ),
            onFieldSubmitted: (str){
              rollingAverageValue.text = str;
              //set state so we can remake thegraph with this rolling average value
              setState(() {
                
              });
            },
            keyboardType: TextInputType.numberWithOptions(
              signed: false,
              decimal: false,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                child: charts.LineChart(
                  createCharts(
                    dateTimes,
                    scanRSSIs,
                    [1],
                    [charts.MaterialPalette.blue.shadeDefault],
                    [5],
                  ),
                  animate: false,
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
                    //showAxisLine: false,
                    viewport: new charts.NumericExtents(
                      minRSSI,
                      maxRSSI,
                    ),
                    //renderSpec: new charts.NoneRenderSpec(),
                  ),
                ),
              )
            ],
          )
        ),
      ],
    );
  }
}