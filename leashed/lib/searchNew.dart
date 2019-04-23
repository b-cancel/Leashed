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
  void initState() {
    super.initState();

    // main init
    ScannerStaticVars.scanResults = new Map<DeviceIdentifier, ScanResult>();
    ScannerStaticVars.allDevicesFound = new Map<String, DeviceData>();
    ScannerStaticVars.isScanning = new ValueNotifier(false);
    ScannerStaticVars.firstStart = new ValueNotifier(true);
    ScannerStaticVars.scanDateTimes = new List<DateTime>();

    // first values in lists (the only false value)
    ScannerStaticVars.scanDateTimes.add(DateTime.now());

    // bluetooth init
    ScannerStaticVars.flutterBlue = FlutterBlue.instance;

    ScannerStaticVars.bluetoothState = BluetoothState.unknown;

    ScannerStaticVars.flutterBlue.state.then((s) {
      setState(() {
        ScannerStaticVars.bluetoothState = s;
      });
    });

    ScannerStaticVars.stateSubscription = ScannerStaticVars.flutterBlue.onStateChanged().listen((s) {
      setState(() {
        ScannerStaticVars.bluetoothState = s;
      });
    });
  }

  @override
  void dispose() {
    ScannerStaticVars.stateSubscription?.cancel();
    ScannerStaticVars.stateSubscription = null;
    ScannerStaticVars.scanSubscription?.cancel();
    ScannerStaticVars.scanSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //managing very annoying bluetooth toggles
    bool bluetoothOn = (ScannerStaticVars.bluetoothState == BluetoothState.on);
    
    if(bluetoothOn && ScannerStaticVars.isScanning == false){
      if(ScannerStaticVars.firstStart.value) startScan();
      else restartScan();
    }
    if(bluetoothOn == false && ScannerStaticVars.isScanning.value) stopScan();

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
          : new BluetoothOffBanner(bluetoothState: ScannerStaticVars.bluetoothState),
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
    );
  }

  //------------------------------Scanning Functions(same in multiple)------------------------------

  void restartScan(){
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      print("---------------auto restart");
      //await Future.delayed(Duration(seconds: 1));
      startScan();
    });
    */
  }

  void startScan(){
    //NOTE: on error isn't being called when an error occurs
    ScannerStaticVars.scanSubscription = ScannerStaticVars.flutterBlue.scan(
      scanMode: ScanMode.lowLatency,
    ).listen((scanResult) {
      if(ScannerStaticVars.isScanning.value == false){
        ScannerStaticVars.isScanning.value = true;
        ScannerStaticVars.firstStart.value = false;
      }
      ScannerStaticVars.scanDateTimes.add(DateTime.now());
      setState(() {
        ScannerStaticVars.scanResults[scanResult.device.id] = scanResult;
        updateDevice(scanResult.device.id);
      });
    }, onDone: stopScan);
  }

  void stopScan() {
    ScannerStaticVars.isScanning.value = false;
    ScannerStaticVars.scanSubscription?.cancel();
    ScannerStaticVars.scanSubscription = null;
  }

  void updateDevice(DeviceIdentifier deviceID){
    String deviceIDstr = deviceID.toString();
    String thisName = ScannerStaticVars.scanResults[deviceID].device.name;
    thisName = (thisName == null) ? "" : thisName;
    BluetoothDeviceType thisType = ScannerStaticVars.scanResults[deviceID].device.type;
    
    bool updateList = false;
    if(ScannerStaticVars.allDevicesFound.containsKey(deviceIDstr) == false){ //-----Adding New Device
      ScannerStaticVars.allDevicesFound[deviceIDstr] = DeviceData(deviceIDstr, thisName, thisType, ScannerStaticVars.scanDateTimes[0]);
      updateList = true;
    }
    else{ //-----MAYBE Update Device
      bool matchingName = ScannerStaticVars.allDevicesFound[deviceIDstr].name != thisName;
      if(matchingName == false){
        ScannerStaticVars.allDevicesFound[deviceIDstr].name = thisName;
        updateList = true;
      }
      //ELSE... name update not required [expected]

      bool matchingType = ScannerStaticVars.allDevicesFound[deviceIDstr].type != thisType;
      if(matchingType == false){
        ScannerStaticVars.allDevicesFound[deviceIDstr].type = thisType;
        updateList = true;
      }
      //ELSE... type update not required [expected]
    }

    //-----Update Device Values
    //NOTE: our scanresults list DOES NOT CLEAR 
    //so if a device disconnects we will just have the last recieved RSSI
    var newRSSI = ScannerStaticVars.scanResults[deviceID].rssi;
    ScannerStaticVars.allDevicesFound[deviceIDstr].add(newRSSI);

    //-----Update Our Main List
    if(updateList) setState(() {});
  }

  List<String> sortResults(){
    //sort by ID
    List<String> deviceIDs = ScannerStaticVars.allDevicesFound.keys.toList();
    deviceIDs.sort();

    //sort all devices by Name
    List<String> withName = new List<String>();
    List<String> withoutName = new List<String>();
    for(int i = 0; i < ScannerStaticVars.allDevicesFound.length; i++){
      String deviceID = deviceIDs[i];
      if(ScannerStaticVars.allDevicesFound[deviceID].name != ""){
        withName.add(deviceID);
      }
      else withoutName.add(deviceID);
    }

    return ([]..addAll(withName))..addAll(withoutName);
  }
}