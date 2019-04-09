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
  Map<String, DeviceDetails> devices = new Map<String, DeviceDetails>();

  ///-------------------------Variables-------------------------

  ///-------------------------Flutter Blue
  
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map(); 
  StreamSubscription _stateSubscription;
  BluetoothState bluetoothState = BluetoothState.unknown;

  ///-------------------------Other
  
  //starts and stops scan depending on bluetooth connection
  bool isScanning = false; //must start FALSE
  //lets user change scan mode (primarily for testing)
  int scanMode = ScanMode.lowLatency.value;

  ///-------------------------Functions-------------------------

  _startScan() {
    isScanning = true;
    _scanSubscription = _flutterBlue.scan(
      scanMode: ScanMode(scanMode),
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

      //display error and link to repair location
      return BluetoothProblem(
        state: bluetoothState,
      );
    }
    else{
      //start scanning if that bluetooth was just turned on
      if(isScanning == false) _startScan();

      //record how long each scan has take
      String alternatingChar = "";
      if(scanTime == dtZero){
        scanTime = DateTime.now();
        alternatingChar = " )(";
      }
      else{
        scanDuration = (DateTime.now()).difference(scanTime);
        scanTime = dtZero;
        alternatingChar = " ()";
      }

      //a list of all the tiles that will be shown in the list view
      updateDeviceList();
      int count = getWithNameCount(devices);
      List<String> deviceIDs = sortResults(devices); 

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
                      devices.keys.toList().length.toString() 
                      + ' (' 
                      + count.toString() 
                      + ') found',
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
        body: new Column(
          children: <Widget>[
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
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: deviceIDs.length,
                itemBuilder: (BuildContext context, int index) {
                  String deviceID = deviceIDs[index];
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
            ),
          ],
        ),
      );
    }
  }

  //"scanResults" stores all the results of this current scan
  //"devices" stores all the results of all scans since we started
  void updateDeviceList(){
    //print("a;lskdfja;lsdfj;lakdsjf;lksajf;lksadjf;lksadjf;lkasjf;lksajdf---START");

    //if new device in "scanResults" we should add it to our "devices"
    List<DeviceIdentifier> keysFromScan = scanResults.keys.toList();
    for(int i = 0; i < keysFromScan.length; i++){
      //get device ID
      DeviceIdentifier thisID = keysFromScan[i];
      String thisName = scanResults[thisID].device.name;
      
      //add new or update name(maybe possible)
      if(devices.containsKey(thisID) == false){ //add new
        //print("**********NEW DEVICE");
        thisName = (thisName == null) ? "" : thisName;
        BluetoothDeviceType thisType = scanResults[thisID].device.type;
        devices[thisID.toString()] = DeviceDetails(thisID.toString(), thisName, thisType);
      }
      else{ //update name?
        if(devices[thisID].name != thisName){
          print("---------------NAME CHANGED " + devices[thisID].name + " => " + thisName);
          if(devices[thisID].name == ""){
            print("---------UPDATED NAME");
            devices[thisID].name = thisName;
          }
        }
      }
    }
    
    //if a device in "devices" is not in "scanResults" then it was disconnected
    //on disconnect we say it has an RSSI of -1000
    List<String> keysFromDevices = devices.keys.toList();
    for(int i = 0; i < keysFromDevices.length; i++){
      //get device ID
      DeviceIdentifier thisID = DeviceIdentifier(keysFromDevices[i]);

      //update OLD or NEW device
      int thisRSSI = -1000; //disconnected
      if(scanResults.containsKey(thisID)){
        //connected RSSI
        thisRSSI = scanResults[thisID].rssi;
      }
      
      //update RSSI of this device
      devices[thisID.toString()].newRSSI(thisRSSI);
    }

    //print("a;lskdfja;lsdfj;lakdsjf;lksajf;lksadjf;lksadjf;lkasjf;lksajdf---END");
  }
}

int getWithNameCount(Map<String, DeviceDetails> devices){
  int count = 0;
  List keys = devices.keys.toList();
  for(int i = 0; i < keys.length; i++){
    String thisName = devices[keys[i]].name;
    if(thisName != "") count += 1;
  }
  return count;
}

List<String> sortResults(Map<String, DeviceDetails> devices){
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