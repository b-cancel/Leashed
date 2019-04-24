import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/pattern/phoneDown.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:leashed/widgets/newDeviceTile.dart';
import 'package:system_setting/system_setting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'scanner.dart';

import 'dart:async';

//NOTE: in order to be able to handle large quantity of devices
//1. we only update the main list if a new device is added

//In order to give live updates of pulse and things relating to it
//1. the heart is in its own seperate widget updating at a particular rate
//---the heart beat is only as long as the fastest update (or some number?)
//2. the last seen updates as often as [1]

class SearchNew extends StatefulWidget {
  @override
  _SearchNewState createState() => _SearchNewState();
}

class _SearchNewState extends State<SearchNew> {
  ///-------------------------Overrides-------------------------
  @override
  Widget build(BuildContext context) {
    //a list of all the tiles that will be shown in the list view
    List<String> deviceIDs = sortResults(); 

    int deviceCount = ScannerStaticVars.allDevicesFound.keys.toList().length;
    String singularOrPlural = (deviceCount == 1) ? "Device" : "Devices";

    //our main widget to return
    return new Scaffold(
      appBar: AppBar(
        title: new Text(
          deviceCount.toString() + ' ' + singularOrPlural + ' Found',
        ),
      ),
      body: new Column(
        children: <Widget>[
          (bluetoothOn)
          ? Container()
          : new BluetoothOffBanner(bluetoothState: ScannerStaticVars.getBluetoothState()),
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.black
            ),
            child: Expanded(
              child: ListView(
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(8.0),
                    itemCount: deviceIDs.length,
                    itemBuilder: (BuildContext context, int index) {
                      String deviceID = deviceIDs[index];
                      DeviceData device = ScannerStaticVars.allDevicesFound[deviceID];
                      return NewDeviceTile(
                        scanDateTimes: ScannerStaticVars.scanDateTimes,
                        devices: ScannerStaticVars.allDevicesFound,
                        device: device,
                      );
                    },
                  ),
                  new Container(
                    height: 65,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      /*
      floatingActionButton: (bluetoothOn)
      //-----Bluetooth Is On
      ? (ScannerStaticVars.isScanning.value) 
      //----------We Are Scanning
      ? FloatingActionButton.extended(
        onPressed: (){
          Navigator.pushReplacement(context, PageTransition(
            type: PageTransitionType.fade,
            duration: Duration.zero, 
            child: PhoneDown(
              allDevicesFound: ScannerStaticVars.allDevicesFound,
              scanDateTimes: ScannerStaticVars.scanDateTimes,
            ),
          ));
        },
        icon: new Icon(
          FontAwesomeIcons.questionCircle,
          size: 18,
        ),
        label: new Text(
          "Can't Identify Your Device?",
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      )
      //----------We Are Not Scanning
      : FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.black,
        onPressed: (){
          startScan();
        },
        icon: new Icon(Icons.refresh),
        label: new Text("Re-Start Scan"),
      )
      //-----Bluetooth Is Off
      : Container(),
      */
    );
  }
}