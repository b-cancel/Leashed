import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/utils.dart';

class DeviceData{
  //should be set once and done
  String id;
  String name; //MIGHT be blank
  BluetoothDeviceType type;

  //scan data syncronize
  DateTime firstScanDateTime;
  DateTime spawnTime;

  //updated every time
  ScanData scanData;

  DeviceData(String initID, String initName, BluetoothDeviceType initType, DateTime initFirstScanDateTime){
    id = initID;
    name = initName;
    type = initType;
    firstScanDateTime = initFirstScanDateTime;
    spawnTime = DateTime.now();

    scanData = new ScanData();
  }

  void add(int newRSSI){
    scanData.add(newRSSI);
  }
}

//NOTE: I know for a fact given that I update a list of lastestScans (contains the latest data for each device)
//when a device disconnects
// - we dont receive any new updates
// - we are just left with whatever the last RSSI value was

int maxSamples = 250;
class ScanData{
  //-----Variable Inits-----

  //NOTE: taking averages for RSSIs at this level does not tell us much
  //to eliminate noise we dont care about averages at a global level
  //since RSSI values can vary heavily
  //we care more about how the value is changing (rate and all)
  List<int> rssiUpdates;
  List<DateTime> rssiUpdateDateTimes;
  List<Duration> rssiIntervalDurations;
  Duration minIntervalDuration;
  Duration maxIntervalDuration;
  Duration averageIntervalDuration;

  //-----Constructor-----
  
  ScanData(){
    rssiUpdates = new List<int>();
    rssiUpdateDateTimes = new List<DateTime>();
    rssiIntervalDurations = new List<Duration>();
  }

  //-----RSSI List-----

  void add(int newRSSI){
    //RSSI Update max
    if(rssiUpdates.length > maxSamples){
      rssiUpdates.clear();
      rssiUpdateDateTimes.clear();
      rssiIntervalDurations.clear();
    }

    rssiUpdates.add(newRSSI);
    rssiUpdateDateTimes.add(DateTime.now());
    if(rssiUpdateDateTimes.length > 1){ //add duration if possible
      int lastIndex = rssiUpdateDateTimes.length - 1;
      DateTime thisScanDateTime = rssiUpdateDateTimes[lastIndex];
      DateTime previousScanDateTime = rssiUpdateDateTimes[lastIndex - 1];
      Duration thisIntervalDuration = thisScanDateTime.difference(previousScanDateTime);
      rssiIntervalDurations.add(thisIntervalDuration);

      //update min max
      if(minIntervalDuration == null){
        minIntervalDuration = thisIntervalDuration;
        maxIntervalDuration = thisIntervalDuration;
      }
      else{
        if(thisIntervalDuration < minIntervalDuration){
          minIntervalDuration = thisIntervalDuration;
        }

        if(thisIntervalDuration > maxIntervalDuration){
          maxIntervalDuration = thisIntervalDuration;
        }
      }

      //update average
      if(averageIntervalDuration == null){
        averageIntervalDuration = thisIntervalDuration;
      }
      else{
        //NOTE: -1 since we already added the newDuration to our List
        int lastCount = rssiIntervalDurations.length - 1;
        averageIntervalDuration = newDurationAverage(averageIntervalDuration, lastCount, thisIntervalDuration);
      }
    }
  }
}

enum Section {neither, left, middle, right}

class PatternAnalyzer{
  List<DateTime> dateTimes;
  List<int> rssi;
  int rssiMin;
  int rssiMax;
  AnAverage total;
  AnAverage left;
  AnAverage middle;
  AnAverage right;

  PatternAnalyzer(){
    dateTimes = new List<DateTime>();
    rssi = new List<int>();
    total = AnAverage();
    left = AnAverage();
    middle = AnAverage();
    right = AnAverage();
  }

  add(int theRssi, DateTime theDateTime, Section theSection){
    //add data
    rssi.add(theRssi);
    dateTimes.add(theDateTime);

    //set min
    if(rssiMin == null) rssiMin = theRssi;
    else rssiMin = (theRssi < rssiMin) ? theRssi : rssiMin;

    //set max
    if(rssiMax == null) rssiMax = theRssi;
    else rssiMax = (theRssi > rssiMax) ? theRssi : rssiMax;

    //update total average
    total.add(theRssi);

    //update any other averages
    switch(theSection){
      case Section.left: left.add(theRssi); break;
      case Section.middle: middle.add(theRssi); break;
      case Section.right: right.add(theRssi); break;
      default: break;
    }
  }
}

class AnAverage{
  double average;
  int itemCount;

  AnAverage(){
    average = 0;
    itemCount = 0;
  }

  add(int newRssi){
    double lastSum = average * itemCount;
    double thisSum = lastSum + newRssi;
    itemCount++; //update the item count
    average = thisSum / itemCount; //update the average
  }

  bool noItems(){
    return (itemCount == 0) ? true : false;
  }

  bool hasItems(){
    return (noItems() == false);
  }
}