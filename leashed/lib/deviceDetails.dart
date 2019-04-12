import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/dataAnalyzer.dart';
import 'package:leashed/data.dart';
import 'package:leashed/utils.dart';

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
      body: Container(),
      
      /*Column(
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
              itemCount: device.scanData.length(),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(8)
                  
                  ,
                  child: Row(
                    children: <Widget>[
                      new Text(device.scanData[index].rssi.toString() + " : "),
                      new Text(durationPrint(device.scanData[index].durationBeforeNewScan())),
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
      */
      floatingActionButton: new FloatingActionButton(
        onPressed: (){
          print("save as json");
        },
        child: new Icon(Icons.save),
      ),
    );
  }
}