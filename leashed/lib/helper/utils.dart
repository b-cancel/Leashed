import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

String durationPrint(dynamic dtOrDur, {bool short = false}){
  //if we pass a datetime we assume
  //we use this time to get a duration
  if(dtOrDur is DateTime){
    dtOrDur = (DateTime.now()).difference(dtOrDur);
  }

  //get all individual values
  int days = dtOrDur.inDays;
  int hours = dtOrDur.inHours;
  int minutes = dtOrDur.inMinutes;
  int seconds = dtOrDur.inSeconds;
  int milliseconds = dtOrDur.inMilliseconds;
  int microseconds = dtOrDur.inMicroseconds;

  //print the largest value
  if(days != 0) return (short) ? "${days}d" : "$days day(s)";
  else if(hours != 0) return (short) ? "${hours}h" : "$hours hour(s)";
  else if(minutes != 0) return (short) ? "${minutes}m" : "$minutes minute(s)";
  else if(seconds != 0) return (short) ? "${seconds}s" : "$seconds second(s)";
  else if(milliseconds != 0) return (short) ? "${milliseconds}l" : "$milliseconds millisec(s)";
  else return (short) ? "${microseconds}i" : "$microseconds microsec(s)";
}

List<int> dateTimeListToDurationInMilliseconds(List<DateTime> dateTimes){
  List<int> timesSince0 = new List<int>();
  DateTime firstDateTime = dateTimes.first;
  for(int i = 0; i < dateTimes.length; i++){
    Duration timeSince0 = dateTimes[i].difference(firstDateTime);
    timesSince0.add(timeSince0.inMilliseconds);
  }
  return timesSince0;
}

List<Map> devicesToJson(Map<String, DeviceData> devices, DateTime scanStart){
  List<Map> devicesSTR = List<Map>();
  List<String> deviceKeys = devices.keys.toList();
  for(int i = 0; i < devices.length; i++){
    //the map to store our device data
    Map device = new Map();
    //the device that will be inspected
    String thisKey = deviceKeys[i];
    DeviceData thisDevice = devices[thisKey];

    //store basic data
    device["id"] = thisDevice.id;
    device["name"] = thisDevice.name ?? "";
    device["type"] = thisDevice.type.toString();
    device["spawnTime"] = thisDevice.spawnTime.toString();
    
    DateTime firstEncounterDateTime = thisDevice.scanData.rssiUpdateDateTimes.first;
    //process complex data
    int millisecondsSinceScanStart = (firstEncounterDateTime).difference(scanStart).inMilliseconds;
    //list to fill with iteration
    List<Map> scanData = new List<Map>();
    //list to interate through
    List<DateTime> theseDateTimesOfUpdates = thisDevice.scanData.rssiUpdateDateTimes;
    List<int> theseRSSIs = thisDevice.scanData.rssiUpdates;
    for(int index = 0; index < theseDateTimesOfUpdates.length; index++){
      //grab this scans data
      int thisRSSI = theseRSSIs[index];
      DateTime thisDuration = theseDateTimesOfUpdates[index];

      //process it
      Duration timeBetweenThisAndFirst = thisDuration.difference(firstEncounterDateTime);
      int thisDurationInMilliseconds = millisecondsSinceScanStart + timeBetweenThisAndFirst.inMilliseconds;

      //build the map and add it
      Map thisMap = new Map();
      thisMap["rssi"] = thisRSSI;
      thisMap["interval"] = thisDurationInMilliseconds;
      scanData.add(thisMap);
    }

    //store complex data
    device["scans"] = scanData;

    //store our dictionary in the global one
    devicesSTR.add(device);
  }
  return devicesSTR;
}

String shortType(BluetoothDeviceType type){
  if(type == BluetoothDeviceType.classic) return 'N';
  else if(type == BluetoothDeviceType.dual) return '2';
  else if(type == BluetoothDeviceType.le) return 'LE';
  else return '?';
}

class Data {
  final int x;
  final y;
  Data(this.x, this.y);
}

xyToList(List<int> x, List y){
  List<Data> xy = new List<Data>();
  for(int i = 0; i < x.length; i++){
    xy.add(Data(x[i], y[i]));
  }
  return xy;
}

//NOTE: this is the specific way we are calculating our rolling average
//1. our returned list MUST be AS LONG as our original list
//2. every value in the returned list MUST USE "valueCount" ammount of values
//  - or as close to this as possible
//3. in the returned list with a valueCount of 3
//  - index i will have the average of values i-2, i-1, i
//  - unless ofcourse the first 2 values are not available in which case it will grab values in front of it
//NOTE: all the magic of this function happens in the [getAverage] function
List rollingAverage(List<int> values, int valueCount){
  if(valueCount < 2) return values;
  else{
    //averages can only occur if ATLEAST 2 values exists
    List<double> rollingAverageList = new List<double>();
    for(int i = 0; i < values.length; i++){
      rollingAverageList.add(getAverage(values, i, valueCount));
    }
    return rollingAverageList;
  }
}

//edge cases and their coverage
//---NOT COVERED (not needed)
//start = end 
//start > end 
//start < end [end NOT in bounds]
//---COVERED
//start < end [end in bounds] && [start in bounds] (1)
//start < end [end in bounds] && [start not in bounds] (2)

//if one overflow 
bool useValuesAhead = false;
double getAverage(List<int> values, int endInclusive, int largestCount){
  int actualCount = (largestCount > values.length) ? values.length : largestCount;

  //remake indices to be more familiar
  int startExclusive = endInclusive - actualCount;
  int startInclusive = startExclusive + 1;
  int endExclusive = endInclusive + 1;

  //reshift the indices if needed
  if(startInclusive < 0){
    if(useValuesAhead){
      //uses values ahead of us if needed
      //NOTE: not helpful at the begining until is has that quant of values
      int shift = startInclusive * -1;
      startInclusive += shift;
      endExclusive += shift;
    }
    else{
      //does not use values ahead
      //eratic at first but helpful quicker
      startInclusive = 0;
      actualCount = endExclusive - startInclusive;
    }
  }

  //make sure our end index is still in range
  //NOTE: this never run
  if(endExclusive > values.length){
    print("aslkfjsadlkfjas;ldfjsa;ldkfjsa;ldkfj;lsakdfj;lsadkfj");
    endInclusive = values.length;
  }

  //get the sum
  int sum = 0;
  for(int i = startInclusive; i < endExclusive; i++){
    sum += values[i];
  }

  return sum / actualCount;
}

charts.Color intToShade(int num){
  if(num == 1) return charts.MaterialPalette.black;
  else if(num == 0) return charts.MaterialPalette.gray.shade800;
  else return charts.MaterialPalette.gray.shade600;
}

String intToString(int num){
  if(num == 1) return "towards";
  else if(num == 0) return "neither";
  else return "away";
}

int eq(int slope, int value){
  return (slope * value) + 1;
}

List<common.AnnotationSegment> createTapHighlights(
    List<int> x,
    List<int> y,
    int lastX,
  ){
    List<common.AnnotationSegment> ranges = new List<common.AnnotationSegment>();
    for(int i = 0; i < y.length; i++){
      charts.Color shade = intToShade(y[i]);
      int thisX = x[i];
      int nextX = i + 1;
      nextX = (nextX == y.length) ? lastX : x[nextX];

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

  List<common.AnnotationSegment> createUpdateLines(timesOfThisDevicesScans){
    List<common.AnnotationSegment> lines = new List<common.AnnotationSegment>();
    for(int i = 0; i < timesOfThisDevicesScans.length; i++){
      int time = timesOfThisDevicesScans[i];
      charts.Color c = charts.Color(r: 255, g: 255, b: 255, a: 32);

      //add to list
      lines.add(
        new charts.LineAnnotationSegment(
          time, 
          charts.RangeAnnotationAxisType.domain,
          color: c,
        ),
      );
    }
    return lines;
  }

  charts.Color indexToColor(int val){
    switch(val){
      case 0: return charts.MaterialPalette.blue.shadeDefault;
      case 1: return charts.MaterialPalette.deepOrange.shadeDefault;
      case 2: return charts.MaterialPalette.green.shadeDefault;
      case 3: return charts.MaterialPalette.yellow.shadeDefault;
      default: return charts.MaterialPalette.purple.shadeDefault;
    }
  }

  int indextoStroke(int val){
    switch(val){
      case 0: return 12;
      case 1: return 10;
      case 2: return 8;
      case 3: return 6;
      default: return 4;
    }
  }

  //1,3,7,15,31
  List<charts.Series<Data, int>> createCharts(
    List<int> x,
    List<int> y,
    List<int> valuesForRollingAverage, //MAX OF 5
  ) {
    List<charts.Series<Data, int>> chartList = new List<charts.Series<Data, int>>();
    for(int i = 0; i < 5; i++){ //MAX OF 5
      int value = valuesForRollingAverage[i];
      chartList.add(
        charts.Series<Data, int>(
          //set manually
          id: value.toString(),
          colorFn: (_, __) => indexToColor(i),
          data: xyToList(x, rollingAverage(y, value)),
          strokeWidthPxFn: (Data sales, _) => indextoStroke(i),
          //set "automatically"
          domainFn: (Data sales, _) => sales.x,
          measureFn: (Data sales, _) => sales.y,
        ),
      );
    }
    return chartList;
  }

List<Map> xyToJson(List<int> x, List<int> y){
  List<Map> res = new List<Map>();
  for(int i = 0; i < x.length; i++){
    Map newMap = new Map();
    newMap["x"] = x[i];
    newMap["y"] = y[i];
    res.add(newMap);
  }
  return res;
}

outputData(String data, BuildContext context) async {
  String actionTaken = "";

  //-----TRY to send as email
  String url = 'mailto:bryan.o.cancel@gmail.com?subject=BLUETOOTH: &body=' + data;

  bool launched = true;
  try {
    if(await canLaunch(url)){
      try {
        await launch(url);
      } catch (e) {
        launched = false;
      }
    }
    else launched = false;
  } catch (e) {
    launched = false;
  }

  //-----TRY to copy to clipboard
  bool copied = true;
  try{
    ClipboardManager.copyToClipBoard(data).then((result) {
      
    }).catchError((){
      copied = false;
    });
  } catch (e) {
    copied = false;
  }

  //-----Alert User of Action
  actionTaken = "If BOTH failed you have TOO MUCH DATA";
  actionTaken += "\n"; 
  actionTaken += (launched) ? "Email Client SHOULD Have Launched" : "Email Client Failed To Launch";
  actionTaken += "\n";
  actionTaken += (copied) ? "Data In Clipboard" : "Data Not Placed In Clipboard";
  final snackBar = SnackBar(
    content: Text(actionTaken),
  );
  Scaffold.of(context).showSnackBar(snackBar);
}

Duration durationAverage(List<Duration> durations){
  int count = durations.length;
  if(count == 0) return Duration.zero;
  else{
    //NOTE: depends on total being able to hold all the microseconds
    Duration sum = Duration.zero;
    //get sum
    for(int i = 0; i < count; i++){
      sum += durations[i];
    }
    //truncations occurs
    //a fraction of a MICROsecond isn't going to make a difference for most applications
    return Duration(microseconds: (sum.inMicroseconds ~/ count));
  }
}

//get new average BEFORE adding newDuration
Duration newDurationAverage(Duration currentAverage, int lastCount, Duration newDuration){
  Duration sum = currentAverage * lastCount;
  sum += newDuration;
  return Duration(microseconds: (sum.inMicroseconds ~/ (lastCount + 1)));
}

Duration durationStandardDeviation(List<Duration> durations, Duration mean){
  int sum = 0;
  int length = durations.length;
  for(int i = 0; i < length; i++){
    Duration valMinusMean = durations[i] - mean;
    sum += pow(valMinusMean.inMicroseconds, 2);
  }
  return Duration(microseconds: sqrt(sum / length).toInt());
}

double deviation(Duration val, Duration mean, Duration stdDev){
  if(stdDev == Duration.zero) return 0;
  else{
    Duration valMinusMean = val - mean;
    double dev = valMinusMean.inMicroseconds / stdDev.inMicroseconds;
    return dev;
  }
}

String nDigitsBehind(double number, int nDigits){
  String str = number.toString();

  //remove negative
  if(number < 0) str = str.substring(1);

  //remove uneeded precision
  int decIndex = str.indexOf(".");
  if(decIndex != -1){
    String before = str.substring(0, decIndex);
    String after = str.substring(decIndex, str.length - 1);

    //remove or add digits
    int digitsAfter = after.length - 1; //after includes .
    if(digitsAfter != nDigits){
      if(digitsAfter < nDigits){ //add digits
        int digitsNeeded = nDigits - digitsAfter;
        while(digitsNeeded > 0){
          str += "0";
          digitsNeeded--;
        }
      }
      else{ //remove digits
        after = after.substring(0, nDigits + 1);
        str = before + after;
      }
    }
    //ELSE... our string is already of the perfect size
  }

  //add negative
  if(number < 0) return "-" + str;
  else return str;
}

String shortBDT(BluetoothDeviceType type){
  if(type == BluetoothDeviceType.classic) return 'Classic';
  else if(type == BluetoothDeviceType.dual) return 'Dual';
  else if(type == BluetoothDeviceType.le) return 'Low Energy';
  else return 'Unknown';
}

//INPUT: -25 -> -125
//OUTPUT: 100 -> 0
num rssiToAdjustedRssi(num rssi){
  num newRssi = rssi + 125;
  //upper bound
  newRssi = (newRssi > 100) ? 100 : newRssi;
  //lower bound
  newRssi = (newRssi < 0) ? 0 : newRssi;
  return newRssi;
}

List<Shadow> textStroke(double thickness, Color color){
  return [
    Shadow( // bottomLeft
      offset: Offset(-thickness, -thickness),
      color: color,
    ),
    Shadow( // bottomRight
      offset: Offset(thickness, -thickness),
      color: color,
    ),
    Shadow( // topRight
      offset: Offset(thickness, thickness),
      color: color,
    ),
    Shadow( // topLeft
      offset: Offset(-thickness, thickness),
      color: color,
    ),
  ];
}

double lerp(double a, double b, double f)
{
  f = (f < 0) ? 0 : f;
  f = (f > 1) ? 1 : f;
  return a + f * (b - a);
}