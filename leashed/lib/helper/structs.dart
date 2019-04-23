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