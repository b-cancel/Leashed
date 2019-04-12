import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/addDevice.dart';
import 'package:leashed/data.dart';
import 'package:leashed/utils.dart';

/*
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
*/

class DeviceData{
  //set once and done
  String id;
  String name; //MIGHT be blank
  BluetoothDeviceType type;
  DateTime spawntime;

  //updated every time
  Scans scans;

/*
  //set multiple times
  int minObservedRSSI;
  int maxObservedRSSI;
  
  //---temporarily filled vars
  List<Signal> allRSSIs;
  List<int> change;
  int peakCount;
  int dropCount;
  */

  DeviceData(String initID, String initName, BluetoothDeviceType initType){
    id = initID;
    name = initName;
    type = initType;
    spawntime = DateTime.now();

    scans = new Scans();

/*
    allRSSIs = new List();
    change = new List();
    peakCount = 0;
    dropCount = 0;
    */
  }

  ns(int rssi){
    
    /*
    if(allRSSIs.length == 0){
      //add initial signal
      allRSSIs.add(new Signal(val));

      //set min/max
      minObservedRSSI = val;
      maxObservedRSSI = val;
    }
    else{
      //ENSURE we dont store the same signal twice
      if(val != allRSSIs.last.rssi){
        //saves how long we had the previous signal
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

        //add new change
        if(allRSSIs.length > 1){
          int thisIndex = allRSSIs.length - 1;
          int prevValue = allRSSIs[thisIndex - 1].rssi;
          int currValue = allRSSIs[thisIndex].rssi;
          change.add(currValue - prevValue);
          
          //add new drop or peak
          if(change.length > 1){
            int thisChangeIndex = change.length - 1;
            int prevChangeValue = change[thisChangeIndex - 1];
            int currChangeValue = change[thisChangeIndex];
            bool prevPos = (prevChangeValue >= 0);
            bool currPos = (currChangeValue >= 0);
            if(prevPos != currPos){
              if(prevPos && currPos == false){
                peakCount += 1;
              }
              else dropCount += 1;
            } 
            //ELSE... we are still rising or till falling
          }
          //ELSE... we dont have enought change data to detect a peak/drop
        } 
        //ELSE... we dont have enough RSSI data to detect a change
      }
      //ELSE... nothing changes
    }
    */
  }  
}

class ValueDisplay extends StatelessWidget {
  final DeviceData device;

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
          /*
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
          */
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: device.scans.length(),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(8)
                  
                  ,
                  child: Row(
                    children: <Widget>[
                      new Text(device.scans[index].rssi.toString() + " : "),
                      new Text(durationPrint(device.scans[index].durationBeforeNewScan())),
                      //new Text(" for "),
                      //new Text(durationPrint(device.allRSSIs[index].dtOrDur)),
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