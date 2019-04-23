import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/home.dart';
import 'dart:async';

//NOTE: this widget is specifically meant to 
//manage our the static variables in "ScannerStaticVars"
//these are then read throughout the entire app

//NOTE: in order to make it possible to mess with the bluetooth setting without messing with the app
//1. IF we start with bluetooth on... if it gets turned off... [3]
//2. IF we start with buetooth off... [3]
//3. the moments its turned on again we reload the page (ideally automatically)

class Scanner extends StatelessWidget {
  //------------------------------Overrides------------------------------

  @override
  Widget build(BuildContext context) {
    // main init
    ScannerStaticVars.scanResults = new Map<DeviceIdentifier, ScanResult>();
    ScannerStaticVars.allDevicesFound = new Map<String, DeviceData>();
    ScannerStaticVars.isScanning = new ValueNotifier(false);
    ScannerStaticVars.firstStart = new ValueNotifier(true);
    ScannerStaticVars.scanDateTimes = new List<DateTime>();
    ScannerStaticVars.showManualRestartButton = new ValueNotifier(false);

    // first value in list (the only false value)
    ScannerStaticVars.scanDateTimes.add(DateTime.now());

    // bluetooth init
    ScannerStaticVars.flutterBlue = FlutterBlue.instance;
    ScannerStaticVars.bluetoothState = BluetoothState.unknown;
    ScannerStaticVars.bluetoothOn = new ValueNotifier(false);
    ScannerStaticVars.flutterBlue.state.then((s) {
      updateBluetoothState(s);
    });
    ScannerStaticVars.stateSubscription = ScannerStaticVars.flutterBlue.onStateChanged().listen((s) {
      updateBluetoothState(s);
    });

    //build actual app
    return HomeStateLess();
  }

  //------------------------------Functions------------------------------

  updateBluetoothState(BluetoothState newState){
    ScannerStaticVars.bluetoothState = newState;
    if(newState == BluetoothState.on) ScannerStaticVars.bluetoothOn.value = true;
    else ScannerStaticVars.bluetoothOn.value = false;
    
    bool bluetoothOn = ScannerStaticVars.bluetoothOn.value;
    bool isScanning = ScannerStaticVars.isScanning.value;
    if(bluetoothOn == true && isScanning == false){
      ScannerStaticVars.showManualRestartButton.value = true;

      if(ScannerStaticVars.firstStart.value) startScan();
      else restartScan();
    }
    else ScannerStaticVars.showManualRestartButton.value = false;
    
    if(bluetoothOn == false && isScanning == true) stopScan();
  }

  void restartScan(){
    print("-----RESTARTING SCANNER");
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
      ScannerStaticVars.scanResults[scanResult.device.id] = scanResult;
      updateDevice(scanResult.device.id);
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
}

class ScannerStaticVars {
  /*
      ScannerStaticVars.scanResults = new Map<DeviceIdentifier, ScanResult>();
    ScannerStaticVars.allDevicesFound = new Map<String, DeviceData>();
    ScannerStaticVars.isScanning = new ValueNotifier(false);
    ScannerStaticVars.firstStart = new ValueNotifier(true);
    ScannerStaticVars.scanDateTimes = new List<DateTime>();
    */
  //regular
  static Map<DeviceIdentifier, ScanResult> scanResults;
  static Map<String, DeviceData> allDevicesFound;
  static ValueNotifier<bool> isScanning; 
  static ValueNotifier<bool> firstStart; 
  static List<DateTime> scanDateTimes;
  static ValueNotifier<bool> showManualRestartButton;

  //bluetooth
  static FlutterBlue flutterBlue;
  static BluetoothState bluetoothState;
  static ValueNotifier<bool> bluetoothOn; //simplification of bluetooth state
  static StreamSubscription stateSubscription;
  static StreamSubscription scanSubscription;

  //functions
  static List<String> sortResults(){
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