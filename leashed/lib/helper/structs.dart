import 'package:flutter_blue/flutter_blue.dart';

class DeviceData{
  //set once and done
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

  //-----Constructor-----
  
  ScanData(){
    rssiUpdates = new List<int>();
    rssiUpdateDateTimes = new List<DateTime>();
  }

  //-----RSSI List-----

  void add(int newRSSI){
    rssiUpdates.add(newRSSI);
    rssiUpdateDateTimes.add(DateTime.now());
  }
}