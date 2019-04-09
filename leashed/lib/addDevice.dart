import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/deviceDetails.dart';
import 'package:system_setting/system_setting.dart';

class AddDevice extends StatefulWidget {

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  Map<DeviceIdentifier, DeviceDetails> devices = new Map<DeviceIdentifier, DeviceDetails>();

 ///-------------------------Variables-------------------------

  FlutterBlue _flutterBlue = FlutterBlue.instance;
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map(); 
  StreamSubscription _stateSubscription;
  BluetoothState bluetoothState = BluetoothState.unknown;
  bool isScanning = false;

  ///-------------------------Functions-------------------------

  _startScan() {
    isScanning = true;
    _scanSubscription = _flutterBlue.scan(
      scanMode: ScanMode.lowLatency,
    ).listen((scanResult) {
      isScanning = true;
      setState(() {
        scanResults[scanResult.device.id] = scanResult;
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

    // start scan (continues until stopped)
    _startScan();
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
      if(isScanning) _stopScan();

      //display error and link to repair location
      return BluetoothProblem(
        state: bluetoothState,
      );
    }
    else{
      //start scanning if that bluetooth was just turned on
      if(isScanning == false) _startScan();

      //record how long each scan has take
      if(scanTime == dtZero){
        scanTime = DateTime.now();
      }
      else{
        scanDuration = (DateTime.now()).difference(scanTime);
        scanTime = dtZero;
      }

      //a list of all the tiles that will be shown in the list view
      int count = getWithNameCount(scanResults);
      List deviceIDs = sortResults(scanResults); 
      updateDets(scanResults);

      //our main widget to return
      return new Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                deviceIDs.toList().length.toString() + ' found in ' + durationPrint(scanDuration),
              ),
              new Text(
                count.toString() + " have names",
              ),
            ],
          ),
        ),
        body: new Stack(
          children: <Widget>[
            ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: deviceIDs.length,
              itemBuilder: (BuildContext context, int index) {
                ScanResult result = scanResults[deviceIDs[index]];

                return InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ValueDisplay(
                          device: devices[result.device.id],
                        ),
                      ),
                    );
                  },
                  child: DeviceTile(
                    //devices has the strings in order as desired
                    result: scanResults[deviceIDs[index]],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  }

  void updateDets(Map<DeviceIdentifier, ScanResult> scanResults){
    List keys = scanResults.keys.toList();
    for(int i = 0; i < keys.length; i++){
      DeviceIdentifier thisID = keys[i];
      int thisRSSI = scanResults[thisID].rssi;

      //add new
      if(devices.containsKey(keys[i]) == false){ 
        DeviceDetails newDD = new DeviceDetails(thisID);
        devices[thisID] = newDD;
      }

      devices[thisID].newRSSI(thisRSSI);
    }
  }
}

int getWithNameCount(Map<DeviceIdentifier, ScanResult> scanResults){
  int count = 0;
  List keys = scanResults.keys.toList();
  for(int i = 0; i < keys.length; i++){
    String thisName = scanResults[keys[i]].device.name;
    if(thisName == "" || thisName == null) count = count;
    else count += 1;
  }
  return count;
}

List<DeviceIdentifier> sortResults(Map<DeviceIdentifier, ScanResult> scanResults){
  //get all DeviceIdentifier keys
  List keys = scanResults.keys.toList();

  //sort our RSSIs
  Map<int, DeviceIdentifier> rssiToKey = new Map<int, DeviceIdentifier>();
  for(int i = 0; i < keys.length; i++){
    DeviceIdentifier thisKey = keys[i];
    int thisRSSI = scanResults[thisKey].rssi;
    rssiToKey[thisRSSI] = thisKey;
  }
  List sortedRSSIs = rssiToKey.keys.toList()..sort();

  //create both maps we will return
  List<DeviceIdentifier> withName = new List<DeviceIdentifier>();
  List<DeviceIdentifier> withoutName = new List<DeviceIdentifier>();

  //sort our map given our sorted RSSI
  for(int i = 0; i < sortedRSSIs.length; i++){
    int thisRSSI = sortedRSSIs[i];
    DeviceIdentifier thisID = rssiToKey[thisRSSI];
    ScanResult thisScanResult = scanResults[thisID];
    String thisName = thisScanResult.device.name;

    if(thisName == "" || thisName == null){
      withoutName.add(thisID);
    }
    else withName.add(thisID);
  }

  return []..addAll(withName)..addAll(withoutName);
}

class BluetoothProblem extends StatelessWidget {
  final BluetoothState state;

  BluetoothProblem({
    this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: (){
          SystemSetting.goto(SettingTarget.BLUETOOTH);
        },
        child: Scaffold(
          body: new Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.redAccent,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Icon(
                    Icons.error,
                    color: Theme.of(context).primaryTextTheme.subhead.color,
                    size: 200,
                  ),
                  new Text(
                    'The Bluetooth Adapter Is ${state.toString().substring(15)}',
                    style: Theme.of(context).primaryTextTheme.subhead,
                  ),
                  new Text(
                    'Tap To Go Into Bluetooth Settings',
                    style: Theme.of(context).primaryTextTheme.subhead,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String durationPrint(Duration dur){
  int days = dur.inDays;
  int hours = dur.inHours;
  int minutes = dur.inMinutes;
  int seconds = dur.inSeconds;
  int milliseconds = dur.inMilliseconds;
  int microseconds = dur.inMicroseconds;

  if(days != 0) return "$days day(s)";
  else if(hours != 0) return "$hours hour(s)";
  else if(minutes != 0) return "$minutes minute(s)";
  else if(seconds !=0) return "$seconds second(s)";
  else if(milliseconds != 0) return "$milliseconds millisec(s)";
  else return "$microseconds microsec(s)";
}

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    this.result
  });

  final ScanResult result;

  Widget _buildTitle(BuildContext context) {
    var name = result.device.name.toString();
    bool nameNotFound = (name == "" || name == null);
    var id = result.device.id.toString();
    //unknown, classic, le, dual
    var type = (result.device.type != BluetoothDeviceType.unknown) ? result.device.type.toString() : "?";
    var rssi = result.rssi.toString();

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
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
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              new Text("RSSI"),
              new Text(rssi),
            ],
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