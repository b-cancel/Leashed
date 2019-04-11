//Keep track of all the classes that keep track of all the data that can then be analyzed to locate a pattern
import 'dart:collection';

//NOTE: I know for a fact given that I update a list of lastestScans (contains the latest data for each device)
//when a device disconnects
// - we dont receive any new updates
// - we are just left with whatever the last RSSI value was

class Scans{
  List<Scan> _scans;

  int minRSSI;
  int maxRSSI;

  int mode; //most occuring
  Map<int,int> rssiToOccurences; //supporting object
  
  double median; //middle value

  double mean; //average

  Scans(){
    _scans = new List<Scan>();
    rssiToOccurences = new Map<int,int>();
    mean = 0;
  }

  void add(int newRSSI){
    //close previous scan if it exists(to record time until new scan [time until this scan])
    if(_scans.length != 0){
      int lastIndex = _scans.length - 1;
      _scans[lastIndex].newScan();
    }

    //add new scan
    _scans.add(Scan(newRSSI));

    //maintain structure that maintains mode
    if(rssiToOccurences.containsKey(newRSSI) == false){
      rssiToOccurences[newRSSI] = 0;
    }
    rssiToOccurences[newRSSI] += 1;

    //maintain min and max
    if(_scans.length == 1){
      minRSSI = newRSSI;
      maxRSSI = newRSSI;
    }
    else{
      minRSSI = (minRSSI < newRSSI) ? minRSSI : newRSSI;
      maxRSSI = (maxRSSI > newRSSI) ? maxRSSI : newRSSI;
    }

    //find new mode (TODO: improve)
    List<int> allRSSIs = rssiToOccurences.keys.toList();
    int keyWithMax = 0; //the first key (guaranteed to exist)
    int max = rssiToOccurences[allRSSIs[keyWithMax]]; //the first value
    for(int i = 1; i < allRSSIs.length; i++){ //start at second value
      int thisKey = allRSSIs[i];
      int thisValue = rssiToOccurences[thisKey];
      if(thisValue > max){
        keyWithMax = i;
        max = thisValue;
      }
    }
    mode = allRSSIs[keyWithMax];

    //find new median
    allRSSIs.sort();
    int mid = (allRSSIs.length ~/2);
    int firstRSSI = allRSSIs[mid];
    if(allRSSIs.length % 2 == 0){
      median = (firstRSSI + allRSSIs[mid - 1])/2;
    }
    else median = firstRSSI.toDouble();

    //maintain average
    int countBefore = _scans.length - 1;
    mean = (newRSSI + (mean * countBefore)) / _scans.length;
  }

  operator [](int i) => _scans[i]; 

  int length(){
    return _scans.length;
  }

  Scan last(){
    return _scans.last;
  }
}

//NOTE: device.state IS NOT useful to determine whether a device is connected
class Scan{
  int rssi;
  dynamic _dtOrDur;
  bool connected; //TODO: make this work
  
  Scan(int initRSSI){
    rssi = initRSSI;
    _dtOrDur  = DateTime.now();
  }

  newScan(){
    _dtOrDur = timeBeforeNewScan();
  }

  Duration timeBeforeNewScan(){
    if(_dtOrDur is DateTime){ //we have not yet been given a new value
      return (DateTime.now()).difference(_dtOrDur);
    }
    else return _dtOrDur;
  }
}