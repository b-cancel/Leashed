//Keep track of all the classes that keep track of all the data that can then be analyzed to locate a pattern
import 'dart:collection';

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

  //TODO... this might vary depending on how many devices are currently connected
  List<Duration> timesBeforeNewScan;

/*
  int mode; //most occuring
  Map<int,int> rssiToOccurences; //supporting object
  
  double median; //middle value

  double mean; //average
  */

  Scans(){
    _scans = new List<Scan>();
    /*
    rssiToOccurences = new Map<int,int>();
    mean = 0;
    */
  }

  void add(int newRSSI){
    //close previous scan if it exists(to record time until new scan [time until this scan])
    if(_scans.length != 0){
      int lastIndex = _scans.length - 1;
      _scans[lastIndex].newScan();
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

    /*
    //maintain structure that maintains mode
    if(rssiToOccurences.containsKey(newRSSI) == false){
      rssiToOccurences[newRSSI] = 0;
    }
    rssiToOccurences[newRSSI] += 1;

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
    */
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