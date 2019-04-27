import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'dart:async';

//NOTE: in order to make it possible to mess with the bluetooth setting without messing with the app
//1. IF we start with bluetooth on... if it gets turned off... [3]
//2. IF we start with buetooth off... [3]
//3. the moments its turned on again we reload the page (ideally automatically)

class ScannerStaticVars {
  //NOTE: ALL value notifers should NOT be set MANUALLY

  //debug
  static bool prints = true; //prints stuff
  static bool printsForUpdates = false; //prints all stuff

  //settings
  static ScanMode _scanMode = ScanMode.lowLatency; //PRIVATE with PUBLIC getter and setter

  //regular
  static final Map<String, DeviceData> allDevicesFound = new Map<String, DeviceData>(); //SHOULD NOT manually add
  static final ValueNotifier<int> allDevicesfoundLength = ValueNotifier(0); //SHOULD NOT manually set

  static final List<DateTime> scanStartDateTimes = [DateTime.now()]; //SHOULD NOT manually add
  static final ValueNotifier<int> scanStartDateTimesLength = ValueNotifier(0); //SHOULD NOT manually set

  static final List<DateTime> scanStopDateTimes = [DateTime.now()]; //SHOULD NOT manually add
  static final ValueNotifier<int> scanStopDateTimesLength = ValueNotifier(0); //SHOULD NOT manually set

  //these are seperate because something starting a scan fails
  //IDEALLY these are always the same value
  //whenever isScanning == true && wantToBeScanning == false => should never happen (unless slight async issue)
  //wehenever isScanning == false && wantToBeScanning == true => we are working towards starting the scan
  static final ValueNotifier<bool> wantToBeScanning = ValueNotifier(false); //SHOULD NOT manually set
  static final ValueNotifier<bool> isScanning = ValueNotifier(false); //SHOULD NOT manually set

  //bluetooth
  static final FlutterBlue _flutterBlue = FlutterBlue.instance; //PRIVATE

  static BluetoothState _bluetoothState = BluetoothState.unknown; //PRIVATE
  static final ValueNotifier<bool> bluetoothOn = ValueNotifier(false); //SHOULD NOT manually set
  static final ValueNotifier<int> bluetoothState = ValueNotifier(BluetoothState.unknown.index); //SHOULD NOT manually set

  static StreamSubscription _stateSubscription; //PRIVATE
  static StreamSubscription _scanSubscription; //PRIVATE

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

  //------------------------------Getters------------------------------
  
  static ScanMode getScanMode() => _scanMode;
  static BluetoothState getBluetoothState() => _bluetoothState;

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
    if(prints && printsForUpdates) print("add to scan start date times");
    scanStartDateTimes.add(value);
    scanStartDateTimesLength.value = scanStartDateTimes.length;
  }

  //ASYNC not needed all operations are very fast BUT -> called very often
  static _addToScanStopDateTimes(DateTime value){
    if(prints && printsForUpdates) print("add to scan stop date times");
    scanStopDateTimes.add(value);
    scanStopDateTimesLength.value = scanStopDateTimes.length;
  }

  //------------------------------Setters------------------------------

  //ASYNC not needed [1] Rarely called and [2] all operations are very fast
  static setScanMode(ScanMode newScanMode){
    if(prints) print("------------------------------set scan mode");
    _scanMode = newScanMode;
    //NOTE: "bluetoothOn" doesn't matter
    //IF isScanning == true => bluetoothOn == true
    //NOTE: "wantToBeScanning" doesn't matter
    //IF isScannign == true => wantToBeScanning == true
    if(isScanning.value){
      if(prints) print("------------------------------set scan mode caused stop then start");
      stopScan();
      startScan(); //since ASYNC so ONLY started here
    }
  }

  //------------------------------Sorting

  static Future<List<String>> sortResults() async{
    if(prints && printsForUpdates) print("sort results");
    //sort by ID
    List<String> deviceIDs = allDevicesFound.keys.toList();
    deviceIDs.sort();

    //seperate with and without name
    List<String> withName = new List<String>();
    List<String> withoutName = new List<String>();
    for(int i = 0; i < allDevicesFound.length; i++){
      String deviceID = deviceIDs[i];
      if(allDevicesFound[deviceID].name != ""){
        withName.add(deviceID);
      }
      else withoutName.add(deviceID);
    }

    //TODO... sort the withName by the devices name NOT it's id

    return ([]..addAll(withName))..addAll(withoutName);
  }

  //------------------------------Debugging

  static scannerStatus() async{
    print("------------------------------|------------------------------");

    print("devices: " + allDevicesfoundLength.value.toString()
    + " starts: " + scanStartDateTimesLength.value.toString()
    + " stops: " + scanStopDateTimesLength.value.toString());

    print("is scanning " + isScanning.value.toString());

    //_flutterBlue
    /*
    bool bleSupport = await _flutterBlue.isAvailable;
    if(bleSupport == false) print("***BLE NOT SUPPORTED");
    else{
      print("is bleOn? think: " + bluetoothOn.toString() + " know: " + (await _flutterBlue.isOn).toString());
      print("state? think: " + _bluetoothState.toString() + " know: " + (await _flutterBlue.state).toString());
    }
    */
    
    /*
    //_stateSubscription
    if(_stateSubscription == null) print("state sub null");
    else print("state subscription " + _stateSubscription.isPaused.toString());
    */

    //_scanSubscription
    if(_scanSubscription == null) print("scan sub null");
    else print("scan subscription " + _scanSubscription.isPaused.toString());

    print("------------------------------|------------------------------");
  }

  //------------------------------Control Scanning Depending on Bluetooth State------------------------------

  //ASYNC not needed [1] rarely called and [2] all operations are very fast
  static updateBluetoothState(BluetoothState newState){
    //-----Do The Updates

    if(prints) print("-------------------------update bluetooth state");
    _bluetoothState = newState;

    //change simplified
    if(newState == BluetoothState.on) bluetoothOn.value = true;
    else bluetoothOn.value = false;

    //change advanced
    bluetoothState.value = newState.index;

    //-----Printer

    bool bluetoothIsOn = bluetoothOn.value;
    bool scanningIsOn = isScanning.value;
    bool weWantToBeScanning = wantToBeScanning.value;

    if(prints){
      print(bluetoothIsOn.toString() + ' ' 
      + scanningIsOn.toString() + ' ' 
      + weWantToBeScanning.toString());
    }

    //-----React Given The Updates

    if(bluetoothIsOn){
      if(scanningIsOn == false){
        if(weWantToBeScanning) startScan();
        //ELSE... bluetooth is on && scanning is not 
        //BUT its okay because we dont want it to be on
      }
      //ELSE... bluetooth is on BUT its okay because scanning is also on
    }
    else{
      //NOTE: "wantToBeScanning" doesn't matter
      //IF isScannign == true => wantToBeScanning == true
      if(scanningIsOn){
        print("-------------------------we should stop the scan cuz bluetooth just died on us");
        stopScan(updateDesire: false); 
      }
      //ELSE... bluetooth is off BUT its okay because scanning is also off
    }
  }

  //------------------------------Scanner Control------------------------------

  //ASYNC not needed [1] rarely called and [2] all operations are very fast
  static stopScan({
    String extraMsg: "",
    bool updateDesire: true,
    }){
    if(extraMsg != "") print(extraMsg);
    pauseScan(
      actuallyStop: true, 
      updateDesire: updateDesire,
    );
  }

  static pauseScan({
    bool actuallyStop: false, 
    bool updateDesire: true,
    }) async{
    //NOTE: wantToBeScanning AND isScanning are SEPERATE
    //this is because we could have want to be scanning BUT NOT successfully started scanning yet

    if(isScanning.value){
      _addToScanStopDateTimes(DateTime.now());
      if(prints){
        String action = actuallyStop ? "stopping" : "pausing";
        print("-------------------------" + action + " scan " + scanStopDateTimesLength.value.toString());
      }

      if(actuallyStop){
        await _scanSubscription?.cancel(); //since ASYNC so ONLY started here
        _scanSubscription = null;
      }
      else{
        _scanSubscription.pause();
      }

      //we set isScanning here so that we know we are done scanning before setting the var
      isScanning.value = false;
    }

    if(updateDesire){
      if(wantToBeScanning.value) wantToBeScanning.value = false;
    }
  }

  //------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------

  //------------------------------MAYBE ASYNC FUNCTIONS------------------------------

  static updateDevice(
    DeviceIdentifier deviceID,
    String deviceName,
    BluetoothDeviceType deviceType,
    int deviceRssi,
    ){
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
  static startScan() async{
    //TODO... should only be possible to switch isScanning on IF bluetooth is on

    if(wantToBeScanning.value == false) wantToBeScanning.value = true;

    //NOTE: on error isn't being called when an error occurs
    if(isScanning.value == false){
      if(prints){
        print("-------------------------trying to start scan STARTED " 
        + bluetoothOn.value.toString());
        scannerStatus(); //TODO... remove debug
      }

      if(_scanSubscription == null){
        print("-------------------------FIRST SCAN start");
         _scanSubscription = _flutterBlue.scan(
          scanMode: _scanMode,
        ).listen((scanResult){
          //set our vars after its begun
          //since it can fail to begin
          _scanStarted();
          
          if(prints && printsForUpdates) print("new scan result");

          //update everything as expected
          updateDevice(
            scanResult.device.id,
            scanResult.device.name,
            scanResult.device.type,
            scanResult.rssi,
          ); 
        });

        //NOTE: I am not worrying about onDone since I have no idea where its triggered
        //TODO... find out where its triggered and handle it appropiately

        _scanSubscription.onError((e){
          print("-------------------------STREAM ERROR-------------------------");
          print(e.toString());
          print("-------------------------STREAM ERROR-------------------------");
        });
      }
      else{
        _scanSubscription.resume(); 
      }

      if(prints){
        print("-------------------------trying to start scan FINISHED " 
        + bluetoothOn.value.toString());
        await scannerStatus(); //TODO... remove debug
      }

      //NOTE: by now we know FOR A FACT that we want the scanner to be running
      //IF it isnt then we need to take steps to make it so...
      if(isScanning.value == false){
        //LISTENER
        //add listener to wantsToBeScanning
        //IF it changes to false then stop the function below

        //FUNCTION
        //wait TIME
        //If isScanning == false => startScan()
        //NOTE: the above only runs if it hasnt already been stoped

        //SADLY... in dart you can't cancel futures... 
        //SO... we do some "hacks"

        wantToBeScanning.addListener(_maybeRemoveForceStartScan);
        wantToBeScanning.value = false;
        wantToBeScanning.value = true;
        //we know its true
        //set it to false => (1st run) will start the function we want (in an if statement)
        //set it to true => (2nd run) nothing... will start actually listening now
        //WE ASSUME that when you remove a listener you also remove all processes it may have started
      }
    }
  }

  static ValueNotifier _runCount = new ValueNotifier(0);
  static _maybeRemoveForceStartScan() async{
    if(_runCount.value == 0){
      print("FIRST RUN");
      _runCount.value++;
      await Future.delayed(Duration(milliseconds: 250));
      print("starting scan as a result of the first listener");
      startScan();
    }
    else if(_runCount.value == 1){
      print("SEOCND RUN");
      _runCount.value++;
    }
    else{
      print("THIRD RUN -> remove ourselves as the listener");
      _runCount.value = 0; //RESET
      wantToBeScanning.removeListener(_maybeRemoveForceStartScan);
    }
  }

  _forceStartScan() async{
    await Future.delayed(Duration(milliseconds: 250));
    startScan();
  }

  static _scanStarted(){
    if(isScanning.value == false){
      _addToScanStartDateTimes(DateTime.now());
      if(prints){
        String action = "started/resumed";
        String scanSessionCount = scanStartDateTimesLength.value.toString();
        print("******************************" + 
        action + " SCAN " + scanSessionCount + 
        "******************************" );
      }
      isScanning.value = true;
    }
    else{
      if(prints && printsForUpdates) print("******************************" + "ALREADY SCANING" + "******************************" );
    }
  }
}