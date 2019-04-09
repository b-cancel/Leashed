import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:system_setting/system_setting.dart';

import 'package:leashed/bleTESTwidgets.dart';

class AddDevice extends StatefulWidget {

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
 ///-------------------------Variables-------------------------

  /// Creating instance of flutter blue
  FlutterBlue _flutterBlue = FlutterBlue.instance;

  /// Scanning
  StreamSubscription _scanSubscription;

  Map<DeviceIdentifier, ScanResult> scanResults = new Map(); 
  bool isScanning = false; 
  /// State of Our Bluetooth Adapter
  StreamSubscription _stateSubscription;

  BluetoothState bluetoothState = BluetoothState.unknown;

  ///-------------------------Functions-------------------------

  _startScan() {
    print("started scan");
    //tell the UI we stopped scanning
    setState(() {
      isScanning = true;
    });

    //start scanning
    _scanSubscription = _flutterBlue.scan(
      scanMode: ScanMode.lowLatency,
    ).listen((scanResult) {
      setState(() {
        scanResults[scanResult.device.id] = scanResult;
        isScanning = false; //tell the UI we stopped scanning
      });
    }, onDone: _stopScan);
  }

  _stopScan() {
    print("stopped scan");
    //TODO... also remove all data from BLE Devices (hinting at scanning not being on)

    //tell the UI we stopped scanning
    setState(() {
      isScanning = false;
    });

    //stop scanning
    _scanSubscription?.cancel();
    _scanSubscription = null;
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
      return BluetoothProblem(
        state: bluetoothState,
      );
    }
    else{
      //start the scan if it isnt
      if(isScanning == false){
        _startScan();
      }

      //record how long each scan has take
      if(scanTime == dtZero){
        scanTime = DateTime.now();
      }
      else{
        scanDuration = (DateTime.now()).difference(scanTime);
        scanTime = dtZero;
      }

      //a list of all the tiles that will be shown in the list view
      var tiles = new List<Widget>();
      tiles.addAll(_buildScanResultTiles());

      //our main widget to return
      return new Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: new Text(
            tiles.toList().length.toString() + ' found in ' + durationPrint(scanDuration),
          ),
        ),
        body: new Stack(
          children: <Widget>[
            (isScanning) ? new LinearProgressIndicator() : new Container(),
            new ListView(
              children: tiles,
            )
          ],
        ),
      );
    }
  }

  ///-------------------------Widgets-------------------------

  _buildScanResultTiles() {
    return scanResults.values.map((r) => ScanResultTile(
      result: r,
      //onTap: () => r.device.id, r.device.name, r.device.type,
    )).toList();
  }
}

class BluetoothProblem extends StatelessWidget {
  final BluetoothState state;

  BluetoothProblem({
    this.state,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        SystemSetting.goto(SettingTarget.BLUETOOTH);
      },
      child: Scaffold(
        body: new Container(
          color: Colors.redAccent,
          child: Column(
            children: <Widget>[
              new Icon(
                Icons.error,
                color: Theme.of(context).primaryTextTheme.subhead.color,
                size: 32,
              ),
              new Text(
                'The Bluetooth Adapter Is ${state.toString().substring(15)}\n'
                + 'Tap To Go Into Bluetooth Settings',
                style: Theme.of(context).primaryTextTheme.subhead,
              ),
            ],
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