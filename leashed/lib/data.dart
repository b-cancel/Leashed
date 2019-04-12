//Keep track of all the classes that keep track of all the data that can then be analyzed to locate a pattern
import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/utils.dart';

class DeviceData{
  //set once and done
  String id;
  String name; //MIGHT be blank
  BluetoothDeviceType type;
  DateTime spawntime;

  //updated every time
  ScanData scanData;

  DeviceData(String initID, String initName, BluetoothDeviceType initType){
    id = initID;
    name = initName;
    type = initType;
    spawntime = DateTime.now();

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
  List<int> allRSSIs;
  /*
  int minRSSI;
  int maxRSSI;
  */

  DateTime lastDateTime;
  List<Duration> durationsBetweenUpdates;
  /*
  Duration minDuration;
  Duration maxDuration;
  Duration mean;
  Duration standardDeviation;
  */

  //-----Constructor-----
  
  ScanData(){
    allRSSIs = new List<int>();
    //minRSSI -> null sets without friction
    //maxRSSI -> null sets without friction
    lastDateTime = DateTime.now();
    durationsBetweenUpdates = new List<Duration>();
    //minDuration -> null sets without friction
    //maxDuration -> null sets without friction
    //mean = Duration.zero;
    //standardDeviation = Duration.zero;
  }

  //-----RSSI List-----

  void add(int newRSSI){
    //we need atleast 2 scans to have a duration between them

    if(allRSSIs.length != 0){
      //record the duration between the last scan and this one
      int lastIndex = allRSSIs.length - 1;
      allRSSIs[lastIndex].newScan();
      Duration newDuration = _scans[lastIndex].durationBeforeNewScan();

      //TODO... IF we did not disconnect after a the last point then we do this
      
      //maintain a running average
      mean = newDurationAverage(mean, durationsBeforeNewScan.length, newDuration);

      //record it seperately so we can find an average to detect a disconnect
      durationsBeforeNewScan.add(DurationBeforeNewScan(
        duration: newDuration,
        devicesConnected: currDevicesConnected,
      ));

      if(newDuration is DateTime){
        print("DATE TIME VALUE");
      }

      //set min max
      /*
      if(durationsBeforeNewScan.length == 1){
        minDuration = newDuration;
        maxDuration = newDuration;
      }
      else{
        minDuration = (minDuration < newDuration) ? minDuration : newDuration;
        maxDuration = (maxDuration > newDuration) ? maxDuration : newDuration;
      }
      */

      //TODO... NOT EDITED... calc standard deviation
      /*
      int sum = 0;
      int length = durationsBeforeNewScan.length;
      for(int i = 0; i < length; i++){
        Duration valMinusMean = durationsBeforeNewScan[i].duration - mean;
        sum += pow(valMinusMean.inMicroseconds, 2);
      }
      standardDeviation = Duration(microseconds: sqrt(sum / length).toInt());
      */

      //now that the scan has been close and the new average and std dev calculated
      _scans[lastIndex].calculateDeviation(mean, standardDeviation);
    }

    //add new scan
    allRSSIs.add(newRSSI);

    //maintain min and max
    /*
    if(allRSSIs.length == 1){
      minRSSI = newRSSI;
      maxRSSI = newRSSI;
    }
    else{
      minRSSI = (minRSSI < newRSSI) ? minRSSI : newRSSI;
      maxRSSI = (maxRSSI > newRSSI) ? maxRSSI : newRSSI;
    }
    */
  }

  operator [](int i) => allRSSIs[i]; 

  int length(){
    return allRSSIs.length;
  }

  int last(){
    return allRSSIs.last;
  }

  //-----Duration List-----

  /*
  Scan(int initRSSI){
    rssi = initRSSI;
    _dtOrDur  = DateTime.now();
    //innocent until proven guilty
    connected = true;
    _deviation = 0;
  }

  newScan(){
    _dtOrDur = durationBeforeNewScan();
  }

  void calculateDeviation(Duration mean, Duration stdDev){
    _deviation = deviation(durationBeforeNewScan(), mean, stdDev);
  }

  double getDeviation(){
    return _deviation;
  }

  Duration durationBeforeNewScan(){
    if(_dtOrDur is DateTime){ //we have not yet been given a new value
      return (DateTime.now()).difference(_dtOrDur);
    }
    else return _dtOrDur;
  }
  */
}