import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'dart:async';

//NOTE: in order to make it possible to mess with the bluetooth setting without messing with the app
//1. IF we start with bluetooth on... if it gets turned off... [3]
//2. IF we start with buetooth off... [3]
//3. the moments its turned on again we reload the page (ideally automatically)

class ScannerStaticVars {
  //settings
  static Duration timeBeforeAutoStart = Duration(seconds: 1); //PUBLIC (once the delay begins its too much of a pain to stop)
  static ValueNotifier<bool> autoStart = ValueNotifier(true); //PUBLIC (should be done before stopping the scan)
  static ScanMode _scanMode = ScanMode.lowLatency; //PRIVATE with PUBLIC getter and setter

  //regular
  static Map<DeviceIdentifier, ScanResult> scanResults = new Map<DeviceIdentifier, ScanResult>(); //SHOULD NOT manually add
  static ValueNotifier<int> scanResultsLength = ValueNotifier(0); //SHOULD NOT manually set

  
  static Map<String, DeviceData> allDevicesFound = new Map<String, DeviceData>(); //SHOULD NOT manually add
  static ValueNotifier<int> allDevicesfoundLength = ValueNotifier(0); //SHOULD NOT manually set

  
  static List<DateTime> scanDateTimes = [DateTime.now()]; //SHOULD NOT manually add
  static ValueNotifier<int> scanDateTimesLength = ValueNotifier(0); //SHOULD NOT manually set

  static ValueNotifier<bool> isScanning = ValueNotifier(false); //SHOULD NOT manually set
  static ValueNotifier<bool> firstStart = ValueNotifier(true); //SHOULD NOT manually set

  //bluetooth
  static FlutterBlue _flutterBlue = FlutterBlue.instance; //PRIVATE

  static BluetoothState _bluetoothState = BluetoothState.unknown; //PRIVATE
  static ValueNotifier<bool> bluetoothOn = ValueNotifier(false); //SHOULD NOT manually set

  static StreamSubscription _stateSubscription; //PRIVATE
  static StreamSubscription _scanSubscription; //PRIVATE

  //combo
  //IF autoStart && (bluetoothOn && isScanning)
  static ValueNotifier<bool> showManualRestartButton = ValueNotifier(false);

  //------------------------------Init------------------------------
  //called by Navigation to start the scanner

  static init(){
    _flutterBlue.state.then((s) {
      updateBluetoothState(s);
    });
    _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
      updateBluetoothState(s);
    });
  }

  //------------------------------Setters------------------------------

  static setScanMode(ScanMode newScanMode){
    if(isScanning.value){
      stopScan();
      _scanMode = newScanMode;
      startScan();
    }
  }

  //------------------------------Getters------------------------------
  
  static ScanMode getScanMode() => _scanMode;
  static BluetoothState getBluetoothState() => _bluetoothState;

  //------------------------------Adders------------------------------

  static _addToScanResults(DeviceIdentifier key, ScanResult value){
    scanResults[key] = value;
    scanResultsLength.value = scanResults.length;
  }

  static _addToAllDevicesFound(String key, DeviceData value){
    allDevicesFound[key] = value;
    allDevicesfoundLength.value = allDevicesFound.length;
  }

  static _addToScanDateTimes(DateTime value){
    scanDateTimes.add(value);
    scanDateTimesLength.value = scanDateTimes.length;
  }

  //------------------------------Functions------------------------------

  static updateBluetoothState(BluetoothState newState){
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

  static void restartScan(){
    print("-----RESTARTING SCANNER");
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      print("---------------auto restart");
      //await Future.delayed(Duration(seconds: 1));
      startScan();
    });
    */
  }

  static void startScan(){
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

  static void stopScan() {
    ScannerStaticVars.isScanning.value = false;
    ScannerStaticVars.scanSubscription?.cancel();
    ScannerStaticVars.scanSubscription = null;
  }

  static void updateDevice(DeviceIdentifier deviceID){
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

/*
  //managing very annoying bluetooth toggles
  bool bluetoothOn = (ScannerStaticVars.bluetoothState == BluetoothState.on);

  if(bluetoothOn && ScannerStaticVars.isScanning == false){
    if(ScannerStaticVars.firstStart.value) startScan();
    else restartScan();
  }
  if(bluetoothOn == false && ScannerStaticVars.isScanning.value) stopScan();
*/

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