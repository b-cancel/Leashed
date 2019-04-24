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
    if(_stateSubscription == null){
      _flutterBlue.state.then((s) {
        updateBluetoothState(s);
      });
      _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
        updateBluetoothState(s);
      });
    }
  }

  //------------------------------Setters------------------------------

  static setScanMode(ScanMode newScanMode){
    _scanMode = newScanMode;
    if(isScanning.value){
      stopScan();
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

  //------------------------------Control Scanning Depending on Bluetooth State------------------------------

  static updateBluetoothState(BluetoothState newState){
    _bluetoothState = newState;
    if(newState == BluetoothState.on) bluetoothOn.value = true;
    else bluetoothOn.value = false;
    
    bool bluetoothIsOn = bluetoothOn.value;
    bool scanningIsOn = isScanning.value;
    if(bluetoothIsOn == true && scanningIsOn == false){
      if(autoStart.value){
        showManualRestartButton.value = true;

        if(firstStart.value) startScan();
        else restartScan();
      }
      else{
        showManualRestartButton.value = false;
      }
    }
    else showManualRestartButton.value = false;
    
    if(bluetoothIsOn == false && scanningIsOn == true) stopScan();
  }

  //------------------------------Scanner Control------------------------------

  static void startScan(){
    //NOTE: on error isn't being called when an error occurs
    if(isScanning.value == false){
      _scanSubscription = _flutterBlue.scan(
        scanMode: _scanMode,
      ).listen((scanResult) {
        //set our vars after its begun
        //since it can fail to begin
        isScanning.value = true;
        firstStart.value = false;

        //update everything as expected
        _addToScanDateTimes(DateTime.now());
        _addToScanResults(scanResult.device.id, scanResult);
        updateDevice(scanResult.device.id);
      }, onDone: stopScan);
    }
  }

  static void restartScan(){
    Future.delayed(timeBeforeAutoStart, () => startScan());
  }

  static void stopScan() {
    if(isScanning.value == true){
      isScanning.value = false;
      _scanSubscription?.cancel();
      _scanSubscription = null;
    }
  }

  //------------------------------Scanner Helper------------------------------

  static void updateDevice(DeviceIdentifier deviceID){
    String deviceIDstr = deviceID.toString();
    
    //-----Adding New Device
    if(allDevicesFound.containsKey(deviceIDstr) == false){ 
      String deviceName = scanResults[deviceID].device.name ?? "";
      BluetoothDeviceType deviceType = scanResults[deviceID].device.type;
      _addToAllDevicesFound(deviceIDstr, DeviceData(deviceIDstr, deviceName, deviceType, scanDateTimes[0]));
    }

    //-----Update Device Values
    //NOTE: our scanresults list DOES NOT CLEAR 
    //so if a device disconnects we will just have the last recieved RSSI
    var newRSSI = scanResults[deviceID].rssi;
    allDevicesFound[deviceIDstr].add(newRSSI);
  }
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