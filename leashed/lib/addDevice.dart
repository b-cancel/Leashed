import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/deviceDetails.dart';
import 'package:leashed/utils.dart';
import 'package:system_setting/system_setting.dart';

class AddDevice extends StatefulWidget {

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  Map<String, DeviceData> devices;

  ///-------------------------Variables-------------------------

  ///-------------------------Flutter Blue
  
  FlutterBlue _flutterBlue;
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults; 
  StreamSubscription _stateSubscription;
  BluetoothState bluetoothState;

  ///-------------------------Other
  
  //starts and stops scan depending on bluetooth connection
  bool isScanning; //must start FALSE
  //lets user change scan mode (primarily for testing)
  int scanMode;
  int connectedDevices;

  ///-------------------------Tests

  //NOTE: can only update data that has been recieved
  //no need to worry about devices that have disconnected
  //the scanner will simply not pick them up
  List<Duration> scanDurations;
  Duration scanDurationsAverage;

  ///-------------------------Functions-------------------------

  _startScan() {
    isScanning = true;
    _scanSubscription = _flutterBlue.scan(
      scanMode: ScanMode(scanMode),
    ).listen((scanResult) {
      //NOTE: this is a SINGLE result
      setState(() {
        scanResults[scanResult.device.id] = scanResult;
        updateDevice(scanResult.device.id);
      });
    }, onDone: _stopScan);
  }

  _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    isScanning = false;
  }

  ///-------------------------Overrides-------------------------

  @override
  void initState() {
    super.initState();

    // var inits
    devices = new Map<String, DeviceData>();
    _flutterBlue = FlutterBlue.instance;
    scanResults = new Map();
    bluetoothState = BluetoothState.unknown;

    isScanning = false;
    scanMode = ScanMode.lowLatency.value;
    connectedDevices = 0;

    // test var init
    scanDurations = new List<Duration>();
    scanDurationsAverage = Duration.zero;

    // Immediately get the state of FlutterBlue
    _flutterBlue.state.then((s) {
      setState(() {
        bluetoothState = s;
      });
    });

    // Subscribe to state changes
    _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
      setState(() {
        bluetoothState = s;
      });
    });

    //NOTE: in the build method scanning start automatically
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    super.dispose();
  }

  static DateTime dtZero = DateTime.fromMicrosecondsSinceEpoch(0);
  DateTime scanTime = DateTime.fromMicrosecondsSinceEpoch(0);
  Duration scanDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    //if our bluetooth isn't on then there is problem
    if (bluetoothState != BluetoothState.on) {
      //stop scanning cuz well... bluetooth is off
      //NOTE: I assume this should happen automatically
      //this is just in case it doesn't (I didn't code flutterblue)
      if(isScanning) _stopScan();
    }
    else{
      //start scanning if that bluetooth was just turned on
      if(isScanning == false) _startScan();
    }

    //a list of all the tiles that will be shown in the list view
    List<String> deviceIDs = sortResults(); 

    //record how long each scan has taken
    //NOTE: this is possible because after every scan setState is called
    String alternatingChar = "";
    if(scanTime == dtZero){
      scanTime = DateTime.now();
      alternatingChar = " )(";
    }
    else{
      scanDuration = (DateTime.now()).difference(scanTime);
      scanTime = dtZero;
      alternatingChar = " ()";

      scanDurationsAverage = newDurationAverage(scanDurationsAverage, scanDurations.length, scanDuration);
      scanDurations.add(scanDuration);
    }

    //updates devices
    checkForDisconnects();

    //checks devices
    connectedDevices = countOfConnectedDevices();

    //our main widget to return
    return new Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    devices.keys.toList().length.toString() + ' Found ' + '(' + connectedDevices.toString() + ')',
                  ),
                  new Text(
                    (durationPrint(scanDuration) + alternatingChar),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white
        ),
        child: new Column(
          children: <Widget>[
            Container(
              color: Colors.blue,
              padding: EdgeInsets.fromLTRB(16,8,16,8),
              alignment: Alignment.centerRight,
              child: new Text(
                "avg of " + scanDurations.length.toString() + " scans: " + durationPrint(scanDurationsAverage),
                textAlign: TextAlign.right,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16,8,16,8),
              width: MediaQuery.of(context).size.width,
              child: DropdownButton<int>(
                value: scanMode,
                onChanged: (int newValue) {
                  //trigger functional change
                  _stopScan();

                  //trigger visual UI change
                  setState(() {
                    scanMode = newValue;
                    //NOTE: this will also start the scan
                  });
                },
                items: [
                  DropdownMenuItem<int>(
                      value: 0,
                      child: Text("Low Power"),
                  ),
                  DropdownMenuItem<int>(
                      value: 1,
                      child: Text("Balanced"),
                  ),
                  DropdownMenuItem<int>(
                      value: 2,
                      child: Text("Low Latency"),
                  ),
                  DropdownMenuItem<int>(
                      value: -1,
                      child: Text("Opportunistic"),
                  ),
                ],
              ),
            ),
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
                    DeviceData device = devices[deviceID];

                    return InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ValueDisplay(
                              device: device,
                            ),
                          ),
                        );
                      },
                      child: DeviceTile(
                        device: device,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int countOfConnectedDevices(){
    List<String> keys = devices.keys.toList();
    int newCount = 0;
    for(int i = 0; i < keys.length; i++){
      String thisKey = keys[i];
      if(devices[thisKey].scans.last().connected){
        newCount += 1;
      }
    }
    return newCount;
  }

  void updateDevice(DeviceIdentifier deviceID){
    String deviceIDstr = deviceID.toString();
    String thisName = scanResults[deviceID].device.name;

    //-----Adding or Updating the Name of a Device (from Scanned)
    if(devices.containsKey(deviceIDstr) == false){ //add new device
      thisName = (thisName == null) ? "" : thisName;
      BluetoothDeviceType thisType = scanResults[deviceID].device.type;
      devices[deviceIDstr] = DeviceData(deviceIDstr, thisName, thisType);
    }
    else{ //update name?
      //TODO... check if this is ever needed
      //NOTE: we have this under the assumption that the name might not always be received
      if(devices[deviceIDstr].name != thisName){
        print("---------------NAME CHANGED " + devices[deviceIDstr].name + " => " + thisName);
        if(devices[deviceIDstr].name == ""){
          print("---------UPDATED NAME");
          devices[deviceIDstr].name = thisName;
          sleep(const Duration(seconds:5));
        }
      }
    }

    //-----Update Device Values
    //NOTE: our scanresults DOES NOT CLEAR so if a device disconnects we will just have the last recieved RSSI
    var newRSSI = scanResults[deviceID].rssi;
    devices[deviceIDstr].scans.add(newRSSI, connectedDevices);
  }

  void checkForDisconnects(){

  }

  List<String> sortResults(){
  //sort by ID
    List<String> deviceIDs = devices.keys.toList();
    deviceIDs.sort();

    //sort all devices by Name
    List<String> withName = new List<String>();
    List<String> withoutName = new List<String>();
    for(int i = 0; i < devices.length; i++){
      String deviceID = deviceIDs[i];
      if(devices[deviceID].name != ""){
        withName.add(deviceID);
      }
      else withoutName.add(deviceID);
    }

    return ([]..addAll(withName))..addAll(withoutName);
  }
}

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    this.device
  });

  final DeviceData device;

  Widget _buildTitle(BuildContext context) {
    var name = device.name.toString();
    bool nameNotFound = (name == "" || name == null);
    var id = device.id.toString();
    //unknown, classic, le, dual
    var type = (device.type != BluetoothDeviceType.unknown) ? device.type.toString() : "?";

    //updated ever so often
    var range = device.scans.minRSSI.toString() + " -> " + device.scans.maxRSSI.toString();
    var mean = device.scans.mean;
    var stdDev = device.scans.standardDeviation;

    //updated every frame
    var rssi = device.scans.last().rssi.toString();
    var time = device.scans.last().durationBeforeNewScan();
    var devsAway = deviations(time, mean, stdDev);

    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                nameNotFound ? "NO NAME" : name,
                style: TextStyle(
                  color: nameNotFound ? Colors.black : Colors.blue,
                  fontSize: nameNotFound ? 12 : 22,
                ),
              ),
              new Text("ID: " + id),
              new Text("TYPE: " + type),
              new Text("RANGE: " + range),
              new Text("MEAN: " + durationPrint(mean)),
              new Text("STD DEV: " + durationPrint(stdDev)),
              /*
              new Text("Peaks: " + device.peakCount.toString()),
              new Text("Drops: " + device.dropCount.toString()),
              */
            ],
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Text("RSSI"),
                new Text(rssi),
                new Text("Time"),
                new Text(durationPrint(time)),
                new Text("Devs"),
                new Text(durationPrint(devsAway)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildTitle(context),
        Divider(),
      ],
    );
  }
}