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
      updateDeviceList();
      int count = getWithNameCount(devices);
      List deviceIDs = sortResults(devices); 

      //our main widget to return
      return new Scaffold(
        appBar: AppBar(
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
                      deviceIDs.toList().length.toString() + ' found',
                    ),
                    new Text(
                      durationPrint(scanTime),
                    ),
                  ],
                ),
                new Text(
                  count.toString() + " have names",
                ),
              ],
            ),
          ),
        ),
        body: new Stack(
          children: <Widget>[
            ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: deviceIDs.length,
              itemBuilder: (BuildContext context, int index) {
                DeviceIdentifier deviceID = deviceIDs[index];
                DeviceDetails device = devices[deviceID];

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
          ],
        ),
      );
    }
  }

  //"scanResults" stores all the results of this current scan
  //"devices" stores all the results of all scans since we started
  void updateDeviceList(){
    //if new device in "scanResults" we should add it to our "devices"
    List keysFromScan = scanResults.keys.toList();
    for(int i = 0; i < keysFromScan.length; i++){
      //get device ID
      DeviceIdentifier thisID = keysFromScan[i];
      
      //add new
      if(devices.containsKey(thisID) == false){ 
        String thisName = scanResults[thisID].device.name;
        thisName = (thisName == null) ? "" : thisName;
        BluetoothDeviceType thisType = scanResults[thisID].device.type;
        devices[thisID] = DeviceDetails(thisID, thisName, thisType);
      }
    }
    
    //if a device in "devices" is not in "scanResults" then it was disconnected
    //on disconnect we say it has an RSSI of -1000
    List keysFromDevices = devices.keys.toList();
    for(int i = 0; i < keysFromDevices.length; i++){
      //get device ID
      DeviceIdentifier thisID = keysFromDevices[i];

      //update OLD or NEW device
      int thisRSSI = -1000; //disconnected
      if(scanResults.containsKey(thisID)){
        //connected RSSI
        thisRSSI = scanResults[thisID].rssi;
      }
      
      //update RSSI of this device
      devices[thisID].newRSSI(thisRSSI);
    }
    
  }
}

int getWithNameCount(Map<DeviceIdentifier, DeviceDetails> devices){
  int count = 0;
  List keys = devices.keys.toList();
  for(int i = 0; i < keys.length; i++){
    String thisName = devices[keys[i]].name;
    if(thisName != "") count += 1;
  }
  return count;
}

List<DeviceIdentifier> sortResults(Map<DeviceIdentifier, DeviceDetails> devices){
  //get all DeviceIdentifier keys
  List keys = devices.keys.toList();

  //sort our RSSIs
  Map<int, DeviceIdentifier> rssiToKey = new Map<int, DeviceIdentifier>();
  for(int i = 0; i < keys.length; i++){
    DeviceIdentifier thisKey = keys[i];
    int thisRSSI = devices[thisKey].allRSSIs.last.rssi;
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
    DeviceDetails thisDevice = devices[thisID];
    String thisName = thisDevice.name;

    if(thisName == ""){
      withoutName.add(thisID);
    }
    else withName.add(thisID);
  }

  return ([]..addAll(withName))..addAll(withoutName);
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

String durationPrint(dynamic dtOrDur){
  //if we pass a datetime we assume
  //we use this time to get a duration
  if(dtOrDur is DateTime){
    dtOrDur = (DateTime.now()).difference(dtOrDur);
  }

  //get all individual values
  int days = dtOrDur.inDays;
  int hours = dtOrDur.inHours;
  int minutes = dtOrDur.inMinutes;
  int seconds = dtOrDur.inSeconds;
  int milliseconds = dtOrDur.inMilliseconds;
  int microseconds = dtOrDur.inMicroseconds;

  //print the largest value
  if(days != 0) return "$days day(s)";
  else if(hours != 0) return "$hours hour(s)";
  else if(minutes != 0) return "$minutes minute(s)";
  else if(seconds !=0) return "$seconds second(s)";
  else if(milliseconds != 0) return "$milliseconds millisec(s)";
  else return "$microseconds microsec(s)";
}

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    this.device
  });

  final DeviceDetails device;

  Widget _buildTitle(BuildContext context) {
    var name = device.name.toString();
    bool nameNotFound = (name == "" || name == null);
    var id = device.id.toString();
    //unknown, classic, le, dual
    var type = (device.type != BluetoothDeviceType.unknown) ? device.type.toString() : "?";
    var rssi = device.allRSSIs.last.rssi.toString();

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