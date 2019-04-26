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
  static final ValueNotifier<bool> autoStart = ValueNotifier(false); //PUBLIC (should be done before stopping the scan)
  static ScanMode _scanMode = ScanMode.lowLatency; //PRIVATE with PUBLIC getter and setter

  //regular
  static final Map<String, DeviceData> allDevicesFound = new Map<String, DeviceData>(); //SHOULD NOT manually add
  static final ValueNotifier<int> allDevicesfoundLength = ValueNotifier(0); //SHOULD NOT manually set

  static final List<DateTime> scanStartDateTimes = [DateTime.now()]; //SHOULD NOT manually add
  static final ValueNotifier<int> scanStartDateTimesLength = ValueNotifier(0); //SHOULD NOT manually set

  static final List<DateTime> scanStopDateTimes = [DateTime.now()]; //SHOULD NOT manually add
  static final ValueNotifier<int> scanStopDateTimesLength = ValueNotifier(0); //SHOULD NOT manually set

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
  //called by Navigation to init the scanner

  //ASYNC not needed [1] Only calld once and [2] all operations are very fast
  static init(){
    if(prints) print("------------------------------try init");
    if(_stateSubscription == null){
      if(prints) print("------------------------------init");
      _flutterBlue.state.then((s){
        updateBluetoothState(s);
      });
      _stateSubscription = _flutterBlue.onStateChanged().listen((s){
        updateBluetoothState(s);
      });
    }
  }

  //------------------------------Setters------------------------------

  //ASYNC not needed [1] Rarely called and [2] all operations are very fast
  static setScanMode(ScanMode newScanMode){
    if(prints) print("------------------------------set scan mode");
    _scanMode = newScanMode;
    if(isScanning.value){
      if(prints) print("------------------------------set scan mode caused stop then start");
      stopScan();
      startScan(); //since ASYNC so ONLY started here
    }
  }

  //------------------------------Getters------------------------------
  
  static ScanMode getScanMode() => _scanMode;
  static BluetoothState getBluetoothState() => _bluetoothState;

  //------------------------------Control Scanning Depending on Bluetooth State------------------------------

  //ASYNC not needed [1] rarely called and [2] all operations are very fast
  static updateBluetoothState(BluetoothState newState){
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
        startScan();
      }
      else{
        showManualRestartButton.value = false;
      }
    }
    else{
      showManualRestartButton.value = false;
      if(bluetoothIsOn == false && scanningIsOn == true) pauseScan();
      //ELSE... we are doing what we want (staying on or off)
    }
  }

  //------------------------------Scanner Control------------------------------

  //ASYNC not needed [1] rarely called and [2] all operations are very fast
  static stopScan(){
    if(isScanning.value == true){
      _addToScanStopDateTimes(DateTime.now());
      if(prints) print("-------------------------stopping scan " + scanStopDateTimesLength.value.toString());
      isScanning.value = false;
      _scanSubscription?.cancel(); //since ASYNC so ONLY started here
      _scanSubscription = null;
    }
  }

  static pauseScan(){
    if(isScanning.value == true){
      _addToScanStopDateTimes(DateTime.now());
      if(prints) print("-------------------------pausing scan " + scanStopDateTimesLength.value.toString());
      isScanning.value = false;
      _scanSubscription.pause();
    }
  }

  //------------------------------MAYBE ASYNC FUNCTIONS------------------------------

  //------------------------------Updaters
  //DONT need to be async but it might be best to make them async since they are called so often

  //ASYNC not needed all operations are very fast BUT -> called very often
  static _addToAllDevicesFound(String key, DeviceData value){
    if(prints && printsForUpdates) print("add to all devices found");
    allDevicesFound[key] = value;
    allDevicesfoundLength.value = allDevicesFound.length;
  }
 
  //ASYNC not needed all operations are very fast BUT -> called very often
  static _addToScanStartDateTimes(DateTime value){
    if(prints && printsForUpdates) print("add to scan date times");
    scanStartDateTimes.add(value);
    scanStartDateTimesLength.value = scanStartDateTimes.length;
  }

  //ASYNC not needed all operations are very fast BUT -> called very often
  static _addToScanStopDateTimes(DateTime value){
    if(prints && printsForUpdates) print("add to scan date times");
    scanStopDateTimes.add(value);
    scanStopDateTimesLength.value = scanStopDateTimes.length;
  }

  static updateDevice(
    DeviceIdentifier deviceID,
    String deviceName,
    BluetoothDeviceType deviceType,
    int deviceRssi,
    )async {
    if(prints && printsForUpdates) print("updating a device");
    String deviceIDstr = deviceID.toString();
    
    //-----Adding New Device
    if(allDevicesFound.containsKey(deviceIDstr) == false){ 
      deviceName = deviceName ?? "";
      _addToAllDevicesFound(deviceIDstr, DeviceData(deviceIDstr, deviceName, deviceType, scanStartDateTimes[0]));
    }

    //-----Update Device Values
    allDevicesFound[deviceIDstr].add(deviceRssi);
  }

  //------------------------------Start/Resume Streamsubscription

  //INIT must have already been called
  //DO NOT USE TO QUICKLY PAUSE
  static startScan(){
    //NOTE: on error isn't being called when an error occurs
    if(isScanning.value == false){
      if(prints){
        print("-------------------------trying to start scan " 
        + bluetoothOn.value.toString());
      }

      if(_scanSubscription == null){
        print("-------------------------FIRST SCAN start");
         _scanSubscription = _flutterBlue.scan(
          scanMode: _scanMode,
        ).listen((scanResult)async {
          //set our vars after its begun
          //since it can fail to begin
          _scanStarted(resumed: false);
          
          if(prints && printsForUpdates) print("new scan result");

          //update everything as expected
          updateDevice(
            scanResult.device.id,
            scanResult.device.name,
            scanResult.device.type,
            scanResult.rssi,
          ); 
        }, onDone: stopScan);

        _scanSubscription.onError((e){
          print("-------------------------STREAM ERROR-------------------------");
          print(e.toString());
          print("-------------------------STREAM ERROR-------------------------");
        });
      }
      else{
        _scanSubscription.resume();
        _scanStarted();
      }
    }
  }

  static _scanStarted({bool resumed: true}){
    if(isScanning.value == false){
      _addToScanStartDateTimes(DateTime.now());
      if(prints){
        String action = (resumed) ? "Resumed" : "Started";
        String scanSessionCount = scanStartDateTimesLength.value.toString();
        print("-------------------------" + action + " scan " + scanSessionCount);
      }
      isScanning.value = true;
      firstStart.value = false;
      showManualRestartButton.value = false; //CHECK
    }
  }

  //------------------------------No Big Deal To Delay New Results Displaying

  static Future<List<String>> sortResults() async{
    if(ScannerStaticVars.prints && ScannerStaticVars.printsForUpdates) print("sort results");
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