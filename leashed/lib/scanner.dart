import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'dart:async';

//NOTE: in order to make it possible to mess with the bluetooth setting without messing with the app
//1. IF we start with bluetooth on... if it gets turned off... [3]
//2. IF we start with buetooth off... [3]
//3. the moments its turned on again we reload the page (ideally automatically)

class ScannerStaticVars {
  static bool prints = true; //prints stuff
  static bool printsForUpdates = false; //prints all stuff

  //settings
  static Duration timeBeforeAutoStart = Duration(seconds: 1); //PUBLIC (once the delay begins its too much of a pain to stop)
  static final ValueNotifier<bool> autoStart = ValueNotifier(true); //PUBLIC (should be done before stopping the scan)
  static ScanMode _scanMode = ScanMode.lowLatency; //PRIVATE with PUBLIC getter and setter

  //regular
  static final Map<DeviceIdentifier, ScanResult> scanResults = new Map<DeviceIdentifier, ScanResult>(); //SHOULD NOT manually add
  static final ValueNotifier<int> scanResultsLength = ValueNotifier(0); //SHOULD NOT manually set

  
  static final Map<String, DeviceData> allDevicesFound = new Map<String, DeviceData>(); //SHOULD NOT manually add
  static final ValueNotifier<int> allDevicesfoundLength = ValueNotifier(0); //SHOULD NOT manually set

  
  static final List<DateTime> scanDateTimes = [DateTime.now()]; //SHOULD NOT manually add
  static final ValueNotifier<int> scanDateTimesLength = ValueNotifier(0); //SHOULD NOT manually set

  static final ValueNotifier<bool> isScanning = ValueNotifier(false); //SHOULD NOT manually set
  static final ValueNotifier<bool> firstStart = ValueNotifier(true); //SHOULD NOT manually set

  //bluetooth
  static final FlutterBlue _flutterBlue = FlutterBlue.instance; //PRIVATE

  static BluetoothState _bluetoothState = BluetoothState.unknown; //PRIVATE
  static final ValueNotifier<bool> bluetoothOn = ValueNotifier(false); //SHOULD NOT manually set
  static final ValueNotifier<int> bluetoothState = ValueNotifier(BluetoothState.unknown.index);

  static StreamSubscription _stateSubscription; //PRIVATE
  static StreamSubscription _scanSubscription; //PRIVATE

  //combo
  //IF autoStart && (bluetoothOn && isScanning)
  static final ValueNotifier<bool> showManualRestartButton = ValueNotifier(false);

  //------------------------------Init------------------------------
  //called by Navigation to start the scanner

  static init() async{
    if(prints) print("------------------------------try init");
    if(_stateSubscription == null){
      if(prints) print("------------------------------init");
      _flutterBlue.state.then((s) async{
        updateBluetoothState(s);
      });
      _stateSubscription = _flutterBlue.onStateChanged().listen((s) async{
        updateBluetoothState(s);
      });
    }
  }

  //------------------------------Setters------------------------------

  static setScanMode(ScanMode newScanMode) async{
    if(prints) print("------------------------------set scan mode");
    _scanMode = newScanMode;
    if(isScanning.value){
      if(prints) print("------------------------------set scan mode caused stop then start");
      await stopScan();
      startScan(); 
    }
  }

  //------------------------------Getters------------------------------
  
  static ScanMode getScanMode() => _scanMode;
  static BluetoothState getBluetoothState() => _bluetoothState;

  //------------------------------Adders------------------------------

  static _addToScanResults(DeviceIdentifier key, ScanResult value) async{
    if(prints && printsForUpdates) print("add to scan results");
    scanResults[key] = value;
    scanResultsLength.value = scanResults.length;
  }

  static _addToAllDevicesFound(String key, DeviceData value) async{
    if(prints && printsForUpdates) print("add to all devices found");
    allDevicesFound[key] = value;
    allDevicesfoundLength.value = allDevicesFound.length;
  }

  static _addToScanDateTimes(DateTime value) async{
    if(prints && printsForUpdates) print("add to scan date times");
    scanDateTimes.add(value);
    scanDateTimesLength.value = scanDateTimes.length;
  }

  //------------------------------Control Scanning Depending on Bluetooth State------------------------------

  static updateBluetoothState(BluetoothState newState) async{
    if(prints) print("-------------------------update bluetooth state");
    _bluetoothState = newState;

    //change simplified
    if(newState == BluetoothState.on) bluetoothOn.value = true;
    else bluetoothOn.value = false;

    //change advanced
    bluetoothState.value = newState.index;
    
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
    else{
      showManualRestartButton.value = false;
      if(bluetoothIsOn == false && scanningIsOn == true) stopScan();
      //ELSE... we are doing what we want (staying on or off)
    }
  }

  //------------------------------Scanner Control------------------------------

  static startScan() async{
    await init();

    //NOTE: on error isn't being called when an error occurs
    if(isScanning.value == false){
      if(prints) print("-------------------------trying to start scan");
      _scanSubscription = _flutterBlue.scan(
        scanMode: _scanMode,
      ).listen((scanResult) async{
        //set our vars after its begun
        //since it can fail to begin
        isScanning.value = true;
        firstStart.value = false;
        showManualRestartButton.value = false;
        if(prints && printsForUpdates) print("new scan result");

        //update everything as expected
        if(allDevicesFound.containsKey(scanResult.device.id.toString()) == false){
          await _addToScanDateTimes(DateTime.now()); 
          await _addToScanResults(scanResult.device.id, scanResult); 
          await updateDevice(scanResult.device.id); 
        }
      }, onDone: stopScan);
    }
  }

  static restartScan() async{
    if(prints) print("-------------------------trying to RE START scan");
    Future.delayed(timeBeforeAutoStart, () => startScan());
  }

  static stopScan() async{
    if(isScanning.value == true){
      if(prints) print("-------------------------stopping scan");
      isScanning.value = false;
      _scanSubscription?.cancel();
      _scanSubscription = null;
    }
  }

  //------------------------------Scanner Helper------------------------------

  static updateDevice(DeviceIdentifier deviceID) async{
    if(prints && printsForUpdates) print("updating a device");
    String deviceIDstr = deviceID.toString();
    
    //-----Adding New Device
    if(allDevicesFound.containsKey(deviceIDstr) == false){ 
      String deviceName = scanResults[deviceID].device.name ?? "";
      BluetoothDeviceType deviceType = scanResults[deviceID].device.type;
      await _addToAllDevicesFound(deviceIDstr, DeviceData(deviceIDstr, deviceName, deviceType, scanDateTimes[0]));
    }

    //-----Update Device Values
    //NOTE: our scanresults list DOES NOT CLEAR 
    //so if a device disconnects we will just have the last recieved RSSI
    var newRSSI = scanResults[deviceID].rssi;
    allDevicesFound[deviceIDstr].add(newRSSI);
  }
}

Future<List<String>> sortResults() async{
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