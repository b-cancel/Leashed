import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/addDevice.dart';

class Signal{
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
  //TODO... lets us remove already added devices 
  //from the add new devices list
  String assignedName;

  //---permanently filled vars
  DeviceIdentifier id;
  String name; //MIGHT be blank
  BluetoothDeviceType  type;
  int minObservedRSSI;
  int maxObservedRSSI;
  
  //---temporarily filled vars
  List<Signal> allRSSIs;

  DeviceDetails(DeviceIdentifier id){
    allRSSIs = new List();
  }

  newRSSI(int val){
    //conclude previous signal if possible
    if(allRSSIs.length >= 1){
      //saves how long we had this signal
      allRSSIs.last.newSignalReceived();
    }

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
          children: <Widget>[
            new Text(device.name),
            new Text(device.id.toString()),
            new Text(device.type.toString()),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: device.allRSSIs.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                //new Text(device.allRSSIs[index].rssi.toString()),
                new Text(" for "),
                //new Text(durationPrint(device.allRSSIs[index].dtOrDur)),
              ],
            ),
          );
        },
      ),
    );
  }
}