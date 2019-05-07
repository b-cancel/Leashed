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
        if(prints) print("-------------------------we should stop the scan cuz bluetooth just died on us");
        stopScan(updateDesire: false); 
      }
      //ELSE... bluetooth is off BUT its okay because scanning is also off
    }
  }

  //------------------------------Scanner Control------------------------------

  //DO NOT IMPLEMENT pausing the scan... resuming the scan at times fails and causes issues
  /*
  From:
  https://docs.flutter.io/flutter/dart-async/StreamSubscription/pause.html

  Info:
  To avoid buffering events on a broadcast stream, 
  it is better to cancel this subscription, 
  and start to listen again when events are needed, 
  if the intermediate events are not important.
  */
  //NOTE: If the subscription is paused more than once, an equal number of resumes must be performed to resume 

  //ASYNC not needed [1] rarely called and [2] all operations are very fast
  static stopScan({
    bool updateDesire: true,
  }) async{
    //NOTE: wantToBeScanning AND isScanning are SEPERATE
    //this is because we could have want to be scanning BUT NOT successfully started scanning yet

    if(isScanning.value){
      _addToScanStopDateTimes(DateTime.now());
      if(prints){
        print("-------------------------stopping scan " + scanStopDateTimesLength.value.toString());
      }

      await _scanSubscription?.cancel(); //since ASYNC so ONLY started here
      _scanSubscription = null;

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

  //------------------------------Start/Resume Streamsubscription

  //NOTE: when we successfully start up the scanner we reset the var below to 0 again

  //this keeps track of how long we are waiting to try and start up the scanner again
  static ValueNotifier<int> msBeforeTryAgain  = new ValueNotifier(0);
  //this is how much we increase our wait time after every failure
  static int msIncrementAfterFailureToRestart = 50; 

  //INIT must have already been called
  static startScan({
    bool updateDesire: true,
    }) async{
    
    if(updateDesire){
      //Regardless of what can we done we want to communicate that we want to be scanning
      if(wantToBeScanning.value == false) wantToBeScanning.value = true;
    }

    //we start the scan depending on whether or not the user desires this
    //NOTE: that this is needed because startScan keep calling itself until it know its active
    //but during this time the user might decide that they dont want to be scanning again
    //if they dont want to be scanning we dont want to update the desire
    if(wantToBeScanning.value){
      //We can only start the scan if bluetooth is on
      if(bluetoothOn.value){
        if(prints) print("SCAN START TRY START");

        //NOTE: on error isn't being called when an error occurs
        if(isScanning.value == false){
          if(prints){
            print("-------------------------trying to start scan STARTED");
            scannerStatus(); //TODO... remove debug
          }

          //get rid of our old failing scan subscriber
          if(_scanSubscription != null){
            await _scanSubscription?.cancel(); //since ASYNC so ONLY started here
            _scanSubscription = null;
          }

          //make the brand new scan subscriber
          if(prints) print("-------------------------TRYING TO START");
          _scanSubscription = _flutterBlue.scan(
            scanMode: _scanMode,
          ).listen((scanResult){
            //set our vars after its begun
            //since it can fail to begin
            //NOTE: this will mark the END of BOTH
            //[1] starting AND [2] resuming
            //NOTE: "wantToBeScanning" AND "bluetoothOn" ARE BOTH TRUE
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
              msBeforeTryAgain.value = 0; //RESET
            }
            //ELSE... is already scanning
            
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

          _scanSubscription.onDone((){
            print("-------------------------STREAM DONE-------------------------");
            print("DONE");
            print("-------------------------STREAM DONE-------------------------");
          });

          _scanSubscription.onError((e){
            print("-------------------------STREAM ERROR-------------------------");
            print(e.toString());
            print("-------------------------STREAM ERROR-------------------------");
          });

          if(prints){
            print("-------------------------trying to start scan FINISHED");
            await scannerStatus(); //TODO... remove debug
          }

          //flicker "wantToBeScanning" so that the button for manual reset 
          //shows up wherever the scanner is being used
          //a flicker is used since we are listening to this in UI where the scanner is being used
          wantToBeScanning.value = false; 
          wantToBeScanning.value = true; 

          //auto restart functionality
          msBeforeTryAgain.value += msIncrementAfterFailureToRestart;
          Future.delayed(
            Duration(milliseconds: msBeforeTryAgain.value), 
            (){
              if(prints) print("*************************RESTART*************************");
              //we dont update the desire because they user may stop the scan before it can actually start
              startScan(updateDesire: false);
            }
          );
        }
        else{
          //ELSE... we have already started scanning
          if(prints) print("CANT START we are already running");
        }

        if(prints) print("SCAN START TRY END");
      }
      else{
        //ELSE... our bluetooth is off so we have to wait for it to turn on to start scanning
        if(prints) print("CANT START bluetooth is off");
      }
    }
    else{
      if(prints) print("-----the user changed their mind... they no longer want to keep restarting the scan");
    }    
  }
}