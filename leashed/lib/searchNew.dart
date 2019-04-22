import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/widgets/newDeviceTile.dart';
import 'package:system_setting/system_setting.dart';

import 'dart:async';

class Analyzer extends StatefulWidget {

  @override
  _AnalyzerState createState() => _AnalyzerState();
}

class _AnalyzerState extends State<Analyzer> {
  Map<String, DeviceData> allDevicesFound;

  ///-------------------------Variables-------------------------

  ///-------------------------Flutter Blue
  
  FlutterBlue flutterBlue;
  StreamSubscription scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults; 
  StreamSubscription stateSubscription;
  BluetoothState bluetoothState;

  ///-------------------------Other

  bool isScanning; //must start FALSE
  bool permaStop;
  List<String> devicesUpdated;

  ///-------------------------Tests

  List<DateTime> scanDateTimes;
  List<DateTime> tapDateTimes;

  ///-------------------------Functions-------------------------

  startScan() {
    isScanning = true;
    scanSubscription = flutterBlue.scan(
      scanMode: ScanMode.lowLatency,
    ).listen((scanResult) {
      scanDateTimes.add(DateTime.now());
      //NOTE: this is a SINGLE result
      setState(() {
        scanResults[scanResult.device.id] = scanResult;
        updateDevice(scanResult.device.id);
      });
    }, onDone: stopScan);
  }

  stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
    isScanning = false;
  }

  ///-------------------------Overrides-------------------------

  @override
  void initState() {
    super.initState();

    // main init
    allDevicesFound = new Map<String, DeviceData>();

    // flutter blue inits
    flutterBlue = FlutterBlue.instance;
    //handle scanSubscription init
    scanResults = new Map();
    //handle subscription init 
    bluetoothState = BluetoothState.unknown;

    // other init
    isScanning = false;
    permaStop = false;
    devicesUpdated = new List<String>();

    // test init
    scanDateTimes = new List<DateTime>();
    tapDateTimes = new List<DateTime>();

    // first values in lists
    scanDateTimes.add(DateTime.now());
    tapDateTimes.add(DateTime.now());

    stateSubscription = flutterBlue.onStateChanged().listen((s) {
      setState(() {
        bluetoothState = s;
      });
    });

    // Immediately get the state of FlutterBlue
    flutterBlue.state.then((s) {
      setState(() {
        bluetoothState = s;
      });
    });
  }

  @override
  void dispose() {
    stateSubscription?.cancel();
    stateSubscription = null;
    scanSubscription?.cancel();
    scanSubscription = null;
    super.dispose();
  }

  String processingGif;

  @override
  Widget build(BuildContext context) {
    //if our bluetooth isn't on then there is problem
    if (bluetoothState != BluetoothState.on) {
      //stop scanning cuz well... bluetooth is off
      //NOTE: I assume this should happen automatically
      //this is just in case it doesn't (I didn't code flutterblue)
      if(isScanning == true) stopScan();
    }
    else{
      //start scanning if that bluetooth was just turned on
      if(isScanning == false && permaStop == false) startScan();
    }

    if(processingGif == null || processingGif == " )(") processingGif = " ()";
    else processingGif = " )(";

    //a list of all the tiles that will be shown in the list view
    List<String> deviceIDs = sortResults(); 

    //our main widget to return
    return new Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: new Text(
          allDevicesFound.keys.toList().length.toString() + ' Found' + processingGif,
        ),
      ),
      body: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white
        ),
        child: new Column(
          children: <Widget>[
            (bluetoothState != BluetoothState.on)
            ? InkWell(
              onTap: (){
                SystemSetting.goto(SettingTarget.BLUETOOTH);
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                width: MediaQuery.of(context).size.width,
                color: Colors.redAccent,
                child: Row(
                  children: <Widget>[
                    new Icon(
                      Icons.error,
                      color: Theme.of(context).primaryTextTheme.subhead.color,
                    ),
                    new Text(
                      'The Bluetooth Adapter Is ${bluetoothState.toString().substring(15)}',
                      style: Theme.of(context).primaryTextTheme.subhead,
                    ),
                  ],
                ),
              ),
            )
            : Container(),
            DefaultTextStyle(
              style: TextStyle(
                color: Colors.black
              ),
              child: Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: deviceIDs.length,
                  itemBuilder: (BuildContext context, int index) {
                    String deviceID = deviceIDs[index];
                    DeviceData device = allDevicesFound[deviceID];
                    return DeviceTile(
                      scaffoldContext: context,
                      scanDateTimes: scanDateTimes,
                      tapDateTimes: tapDateTimes,
                      devices: allDevicesFound,
                      device: device,
                      updatedThisFrame: checkIfUpdatedThisFrame(device.id),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return (permaStop == false)
        ? new FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: (){
            permaStop = true;
            stopScan();
          },
          child: new Icon(Icons.stop),
        )
        : Container();
      }),
    );
  }

  bool checkIfUpdatedThisFrame(String deviceID){
    if(devicesUpdated.contains(deviceID)){
      devicesUpdated.remove(deviceID);
      return true;
    }
    else return false;
  }

  void updateDevice(DeviceIdentifier deviceID){
    String deviceIDstr = deviceID.toString();
    String thisName = scanResults[deviceID].device.name;

    //-----Adding New Device
    if(allDevicesFound.containsKey(deviceIDstr) == false){ //add new device
      thisName = (thisName == null) ? "" : thisName;
      BluetoothDeviceType thisType = scanResults[deviceID].device.type;
      allDevicesFound[deviceIDstr] = DeviceData(deviceIDstr, thisName, thisType, scanDateTimes[0]);
    }

    //-----Update Device Values
    //NOTE: our scanresults DOES NOT CLEAR so if a device disconnects we will just have the last recieved RSSI
    var newRSSI = scanResults[deviceID].rssi;
    allDevicesFound[deviceIDstr].add(newRSSI);

    //-----Tell the UI We Updated
    //extra if needed since we might update a device multiple times before the frame shows
    if(devicesUpdated.contains(deviceIDstr) == false){
      devicesUpdated.add(deviceIDstr);
    }
  }

  List<String> sortResults(){
  //sort by ID
    List<String> deviceIDs = allDevicesFound.keys.toList();
    deviceIDs.sort();

    //sort all devices by Name
    List<String> withName = new List<String>();
    List<String> withoutName = new List<String>();
    for(int i = 0; i < allDevicesFound.length; i++){
      String deviceID = deviceIDs[i];
      if(allDevicesFound[deviceID].name != ""){
        withName.add(deviceID);
      }
      else withoutName.add(deviceID);
    }

    return ([]..addAll(withName))..addAll(withoutName);
  }
}