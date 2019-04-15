import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/structs.dart';
import 'package:leashed/utils.dart';
import 'package:system_setting/system_setting.dart';

/*

class SearchNew extends StatefulWidget {

  @override
  _SearchNewState createState() => _SearchNewState();
}

class _SearchNewState extends State<SearchNew> {
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

  ///-------------------------Tests

  //NOTE: can only update data that has been recieved
  //no need to worry about devices that have disconnected
  //the scanner will simply not pick them up
  DateTime firstScanDT;

  List<Duration> scanDurations;
  Duration scanDurationsAverage;
  Duration scanDurationsStandardDeviation;

  DateTime lastTapTime;
  List<Duration> timeBetweenTaps;
  List<int> tapValues;

  ///-------------------------Functions-------------------------

  _startScan() {
    isScanning = true;
    _scanSubscription = _flutterBlue.scan(
      scanMode: ScanMode.lowLatency,
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

    // test var init
    firstScanDT = DateTime.now();

    scanDurations = new List<Duration>();
    scanDurationsAverage = Duration.zero;
    scanDurationsStandardDeviation = Duration.zero;

    lastTapTime = firstScanDT;
    timeBetweenTaps = new List<Duration>();
    tapValues = new List<int>();

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
      scanDurationsStandardDeviation = durationStandardDeviation(scanDurations, scanDurationsAverage);
    }

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
                    devices.keys.toList().length.toString() + ' Found',
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
              padding: EdgeInsets.all(8),
              color: Colors.blue,
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: new Text(
                      "avg of " + scanDurations.length.toString() + " scans: " + durationPrint(scanDurationsAverage),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Divider(),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: new Text(
                      "with std dev: " + durationPrint(scanDurationsStandardDeviation),
                      textAlign: TextAlign.right,
                    ),
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
      floatingActionButton: new FloatingActionButton(
        onPressed: (){
          _showDialog();
        },
        child: new Icon(Icons.gradient),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Table(
            children: [
              TableRow(

              ),
              TableRow(

              ),
              TableRow(

              ),
            ],
          )
        );
      },
    );
  }

  void updateDevice(DeviceIdentifier deviceID){
    String deviceIDstr = deviceID.toString();
    String thisName = scanResults[deviceID].device.name;

    //-----Adding New Device
    if(devices.containsKey(deviceIDstr) == false){ //add new device
      thisName = (thisName == null) ? "" : thisName;
      BluetoothDeviceType thisType = scanResults[deviceID].device.type;
      devices[deviceIDstr] = DeviceData(deviceIDstr, thisName, thisType, firstScanDT);
    }

    //-----Update Device Values
    //NOTE: our scanresults DOES NOT CLEAR so if a device disconnects we will just have the last recieved RSSI
    var newRSSI = scanResults[deviceID].rssi;
    devices[deviceIDstr].add(newRSSI);
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

    //updated every frame
    var rssi = device.scanData.allRSSIs.last;
    List durs = device.scanData.durationsBetweenUpdates;
    Duration durationSoFar = (DateTime.now()).difference(device.scanData.lastDateTime);
    if(durs.length != 0){ //update last duration (IF present)
      durs[durs.length - 1] = durationSoFar;
    }
    else{
      durs.add(durationSoFar);
    }
    var time = device.scanData.durationsBetweenUpdates.last;

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
              new Text("Since First " + durationPrint(device.timeSinceScanStart))
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
                new Text(rssi.toString()),
                new Text("Time"),
                new Text(durationPrint(time)),
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

*/