import 'package:flutter/material.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;
import 'package:intl/intl.dart' as intl;

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

class UpdatingScanner extends StatefulWidget {
  final String deviceID;

  UpdatingScanner({
    this.deviceID,
  });

  @override
  _UpdatingScannerState createState() => _UpdatingScannerState();
}

class _UpdatingScannerState extends State<UpdatingScanner> {

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

    //---Sizing for our Scanner
    double width = MediaQuery.of(context).size.width;
    double height = width * (3/4);

    //---Return Our Widget
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              height: height,
              width: width,
              color: Navigation.blueGrey,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              child: charts.LineChart(
                createCharts(
                  dateTimes,
                  scanRSSIs,
                  [1],
                  [charts.MaterialPalette.blue.shadeDefault],
                  [5],
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
              child: new WhiteCircle(
                value: "max"
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: new WhiteCircle(
                value: "min"
              ),
            ),
          ],
        ),
        FlutterSlider(
          values: [300],
          max: 500,
          min: 0,
          onDragging: (handlerIndex, lowerValue, upperValue) {
            /*
            _lowerValue = lowerValue;
            _upperValue = upperValue;
            */
            setState(() {});
          },
          handler: FlutterSliderHandler(
            decoration: BoxDecoration(),
            child: Material(
              type: MaterialType.canvas,
              color: Colors.orange,
              elevation: 3,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.adjust, 
                  size: 25,
                ),
              ),
            ),
          ),
          rightHandler: FlutterSliderHandler(
            child: Icon(Icons.chevron_left, color: Colors.red, size: 24,),
          ),
          handlerAnimation: FlutterSliderHandlerAnimation(
            curve: Curves.elasticOut,
            reverseCurve: Curves.bounceIn,
            duration: Duration(milliseconds: 500),
            scale: 1.5
          ),
          trackBar: FlutterSliderTrackBar(
            activeTrackBarColor: Colors.redAccent,
            activeTrackBarHeight: 5,
            inactiveTrackBarColor: Colors.greenAccent.withOpacity(0.5),
          ),
          tooltip: FlutterSliderTooltip(
            textStyle: TextStyle(fontSize: 17, color: Colors.white),
            leftPrefix: Icon(Icons.attach_money, size: 19, color: Colors.black45,),
            rightSuffix: Icon(Icons.attach_money, size: 19, color: Colors.black45,),
            boxStyle: FlutterSliderTooltipBox(
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.7)
              )
            ),
            numberFormat: intl.NumberFormat(),
            // numberFormat: intl.NumberFormat(),
          ),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }

  List<common.AnnotationSegment> highlightErrorRanges(List<int> intervals, int value){
    List<common.AnnotationSegment> ranges = new List<common.AnnotationSegment>();
    for(int i = 0; i < (intervals.length - 1); i += 2){
      charts.Color shade = charts.MaterialPalette.gray.shade500;
      int thisX = intervals[i];
      int nextX = intervals[i + 1];

      //add to list
      ranges.add(
        new charts.RangeAnnotationSegment(
          thisX, 
          nextX, 
          charts.RangeAnnotationAxisType.domain,
          color: shade,
        )
      );
    }
    return ranges;
  }
}

class WhiteCircle extends StatelessWidget {
  final String value;

  const WhiteCircle({
    this.value,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white,
        ),
        child: new Text(
          value,
          style: TextStyle(
            color: Navigation.blueGrey,
          ),
        ),
      ),
    );
  }
}