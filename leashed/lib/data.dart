//Keep track of all the classes that keep track of all the data that can then be analyzed to locate a pattern
import 'dart:collection';
import 'dart:math';

import 'package:leashed/utils.dart';

//NOTE: I know for a fact given that I update a list of lastestScans (contains the latest data for each device)
//when a device disconnects
// - we dont receive any new updates
// - we are just left with whatever the last RSSI value was

class Scans{
  int minRSSI;
  int maxRSSI;
  List<Scan> _scans;

  //NOTE: taking averages for RSSIs at this level does not tell us much
  //to eliminate noise we dont care about averages at a global level
  //since RSSI values can vary heavily
  //we care more about how the value is changing (rate and all)

  //-----Average Tracking for "timeBeforeNewScan"
  //NOTE: we don't want to consider points taken BEFORE disconnecting
  //this is because although technically they were received
  //since you disconnected we don't have an accurate "timeBeforeNewScan"
  //so it's guaranteed to skew our data in a direction we know to be incorrect

  //NOTE: because we track how many devices we have we can caculate that average if desired
  List<DurationBeforeNewScan> durationsBeforeNewScan;
  Duration mean; //arithmetic mean (average)
  //both use mean as the "measure of central tendency"
  Duration standardDeviation;
  
  Scans(){
    _scans = new List<Scan>();
    durationsBeforeNewScan = new List<DurationBeforeNewScan>();
    mean = Duration.zero;
    standardDeviation = Duration.zero;
  }

  void add(int newRSSI, int currDevicesConnected){
    //we need atleast 2 scans to have a duration between them
   
    if(_scans.length != 0){
      //record the duration between the last scan and this one
      int lastIndex = _scans.length - 1;
      _scans[lastIndex].newScan();
      Duration newDuration = _scans[lastIndex].durationBeforeNewScan();

      //IF we did not disconnect after a the last point
      if(_scans[lastIndex].connected){
        //maintain a running average
        mean = newDurationAverage(mean, durationsBeforeNewScan.length, newDuration);

        //record it seperately so we can find an average to detect a disconnect
        durationsBeforeNewScan.add(DurationBeforeNewScan(
          duration: newDuration,
          devicesConnected: currDevicesConnected,
        ));

        //calc standard deviation
        int sum = 0;
        int length = durationsBeforeNewScan.length;
        for(int i = 0; i < length; i++){
          Duration valMinusMean = durationsBeforeNewScan[i].duration - mean;
          sum += pow(valMinusMean.inMicroseconds, 2);
        }
        standardDeviation = Duration(microseconds: sqrt(sum / length).toInt());
      }
    }

    //add new scan
    _scans.add(Scan(newRSSI));

    //maintain min and max
    if(_scans.length == 1){
      minRSSI = newRSSI;
      maxRSSI = newRSSI;
    }
    else{
      minRSSI = (minRSSI < newRSSI) ? minRSSI : newRSSI;
      maxRSSI = (maxRSSI > newRSSI) ? maxRSSI : newRSSI;
    }
  }

  operator [](int i) => _scans[i]; 

  int length(){
    return _scans.length;
  }

  Scan last(){
    return _scans.last;
  }
}

class DurationBeforeNewScan{
  //uses the assumed value
  //IF it hasn't been confirmed that a device is disconnected then its considered connected
  int devicesConnected;
  Duration duration;
  DurationBeforeNewScan({
    this.devicesConnected,
    this.duration,
  });
}

//NOTE: device.state IS NOT useful to determine whether a device is connected
class Scan{
  int rssi;
  dynamic _dtOrDur;
  bool connected; 
  
  Scan(int initRSSI){
    rssi = initRSSI;
    _dtOrDur  = DateTime.now();
    //innocent until proven guilty
    connected = true;
  }

  newScan(){
    _dtOrDur = durationBeforeNewScan();
  }

  Duration durationBeforeNewScan(){
    if(_dtOrDur is DateTime){ //we have not yet been given a new value
      return (DateTime.now()).difference(_dtOrDur);
    }
    else return _dtOrDur;
  }
}