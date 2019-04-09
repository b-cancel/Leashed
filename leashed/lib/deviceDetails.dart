import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/addDevice.dart';

class Signal{
  //NOTE: an rssi of -1000 is a disconnected device
  int rssi;
  //initially its a "date time"
  //after a new signal is received it becomes a "duration"
  dynamic dtOrDur;

  Signal(int val){
    rssi = val;
    dtOrDur = DateTime.now();
  }

  newSignalReceived(){
    dtOrDur = (DateTime.now()).difference(dtOrDur);
  }
}

class DeviceDetails{
  //TODO... 
  //1. lets us remove already added devices 
  //from the add new devices list
  //2. lets us display a device name when it doesnt have a friendly one
  String assignedName;

  //---permanently filled vars
  //set once and done
  String id;
  String name; //MIGHT be blank
  BluetoothDeviceType type;

  //set multiple times
  int minObservedRSSI;
  int maxObservedRSSI;
  
  //---temporarily filled vars
  List<Signal> allRSSIs;

  DeviceDetails(String initID, String initName, BluetoothDeviceType initType){
    id = initID;
    name = initName;
    type = initType;
    allRSSIs = new List();
  }

  newRSSI(int val){
    if(allRSSIs.length == 0){
      //add initial signal
      allRSSIs.add(new Signal(val));

      //set min/max
      minObservedRSSI = val;
      maxObservedRSSI = val;
    }
    else{
      if(val != allRSSIs.last.rssi){
        //saves how long we had this signal
        allRSSIs.last.newSignalReceived();

        //add new signal with zero duration
        allRSSIs.add(new Signal(val));

        // new min?
        if(minObservedRSSI == null) minObservedRSSI = val;
        else{
          minObservedRSSI = (minObservedRSSI < val) ? minObservedRSSI : val;
        }

        // new max?
        if(maxObservedRSSI == null) maxObservedRSSI = val;
        else{
          maxObservedRSSI = (maxObservedRSSI > val) ? maxObservedRSSI : val;
        }
      }
      //ELSE... nothing changes
    }
  }  

  clearRSSIs(){
    allRSSIs.clear();
  }
}

class ValueDisplay extends StatelessWidget {
  final DeviceDetails device;

  ValueDisplay({
    this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(device.name + " " + device.type.toString()),
            new Text(device.id.toString()),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.white,
            ),
            child: Container(
              color: Colors.blue,
              padding: EdgeInsets.all(16),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text(
                      "Min: " + device.minObservedRSSI.toString(), 
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: new Text(
                      "Max: " + device.maxObservedRSSI.toString(), 
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: new Text(
                      "Dif: " + (device.maxObservedRSSI - device.minObservedRSSI).toString(), 
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: device.allRSSIs.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      new Text(device.allRSSIs[index].rssi.toString()),
                      new Text(" for "),
                      new Text(durationPrint(device.allRSSIs[index].dtOrDur)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}