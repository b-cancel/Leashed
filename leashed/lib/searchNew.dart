import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:leashed/widgets/newDeviceTile.dart';
import 'package:system_setting/system_setting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:async';

//NOTE: in order to make it possible to mess with the bluetooth setting without messing with the app
//1. IF we start with bluetooth on... if it gets turned off... [3]
//2. IF we start with buetooth off... [3]
//3. the moments its turned on again we reload the page

//NOTE: in order to be able to handle large quantity of devices
//1. we only update the main list if a new device is added

//In order to give live updates of pulse and things relating to it
//1. the heart is in its own seperate widget updating at a particular rate
//---the heart beat is only as long as the fastest update (or some number?)
//2. the last seen updates as often as [1]

class SearchNew extends StatefulWidget {
  final Map<String, DeviceData> allDevicesFound;

  SearchNew({
    this.allDevicesFound,
  });

  @override
  _SearchNewState createState() => _SearchNewState();
}

class _SearchNewState extends State<SearchNew> {
  ///-------------------------Variables-------------------------

  ///-------------------------Other

  Map<DeviceIdentifier, ScanResult> scanResults; 
  Map<String, DeviceData> allDevicesFound;
  bool isScanning; //must start FALSE
  bool firstStart; //must start TRUE
  List<DateTime> scanDateTimes;

  ///-------------------------Bluetooth
  
  FlutterBlue flutterBlue;
  BluetoothState bluetoothState;
  StreamSubscription stateSubscription;
  StreamSubscription scanSubscription;

  ///-------------------------Overrides-------------------------

  @override
  void initState() {
    super.initState();

    // main init
    scanResults = new Map<DeviceIdentifier, ScanResult>();
    if(widget.allDevicesFound == null){
      allDevicesFound = new Map<String, DeviceData>();
    }
    else{
      allDevicesFound = widget.allDevicesFound;
    }
    isScanning = false;
    firstStart = true;
    scanDateTimes = new List<DateTime>();

    // first values in lists (the only false value)
    scanDateTimes.add(DateTime.now());

    // bluetooth init
    flutterBlue = FlutterBlue.instance;

    bluetoothState = BluetoothState.unknown;

    flutterBlue.state.then((s) {
      setState(() {
        bluetoothState = s;
      });
    });

    stateSubscription = flutterBlue.onStateChanged().listen((s) {
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

  @override
  Widget build(BuildContext context) {
    //managing very annoying bluetooth toggles
    bool bluetoothOn = (bluetoothState == BluetoothState.on);
    
    if(bluetoothOn && isScanning == false){
      if(firstStart) startScan();
      else restartScan();
    }
    if(bluetoothOn == false && isScanning) stopScan();

    //a list of all the tiles that will be shown in the list view
    List<String> deviceIDs = sortResults(); 

    int deviceCount = allDevicesFound.keys.toList().length;
    String singularOrPlural = (deviceCount == 1) ? "Device" : "Devices";

    //our main widget to return
    return new Scaffold(
      appBar: AppBar(
        title: new Text(
          deviceCount.toString() + ' ' + singularOrPlural + ' Found',
        ),
      ),
      body: new Column(
        children: <Widget>[
          (bluetoothOn)
          ? Container()
          : new BluetoothOffBanner(bluetoothState: bluetoothState),
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.black
            ),
            child: Expanded(
              child: ListView(
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(8.0),
                    itemCount: deviceIDs.length,
                    itemBuilder: (BuildContext context, int index) {
                      String deviceID = deviceIDs[index];
                      DeviceData device = allDevicesFound[deviceID];
                      return NewDeviceTile(
                        scanDateTimes: scanDateTimes,
                        devices: allDevicesFound,
                        device: device,
                      );
                    },
                  ),
                  new Container(
                    height: 65,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (bluetoothOn)
      //-----Bluetooth Is On
      ? (isScanning) 
      //----------We Are Scanning
      ? FloatingActionButton.extended(
        onPressed: (){
          Navigation.appRouter.navigateTo(context, "phoneDown", transition: TransitionType.inFromBottom);
        },
        icon: new Icon(
          FontAwesomeIcons.questionCircle,
          size: 18,
        ),
        label: new Text(
          "Can't Identify Your Device?",
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      )
      //----------We Are Not Scanning
      : FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.black,
        onPressed: (){
          startScan();
        },
        icon: new Icon(Icons.refresh),
        label: new Text("Re-Start Scan"),
      )
      //-----Bluetooth Is Off
      : Container(),
    );
  }

  void restartScan(){
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      print("---------------auto restart");
      //await Future.delayed(Duration(seconds: 1));
      startScan();
    });
    */
  }

  void startScan(){
    //NOTE: on error isn't being called when an error occurs
    scanSubscription = flutterBlue.scan(
      scanMode: ScanMode.lowLatency,
    ).listen((scanResult) {
      if(isScanning == false){
        isScanning = true;
        firstStart = false;
      }
      scanDateTimes.add(DateTime.now());
      setState(() {
        scanResults[scanResult.device.id] = scanResult;
        updateDevice(scanResult.device.id);
      });
    }, onDone: stopScan);
  }

  void stopScan() {
    isScanning = false;
    scanSubscription?.cancel();
    scanSubscription = null;
  }

  void updateDevice(DeviceIdentifier deviceID){
    String deviceIDstr = deviceID.toString();
    String thisName = scanResults[deviceID].device.name;
    thisName = (thisName == null) ? "" : thisName;
    BluetoothDeviceType thisType = scanResults[deviceID].device.type;
    
    bool updateList = false;
    if(allDevicesFound.containsKey(deviceIDstr) == false){ //-----Adding New Device
      allDevicesFound[deviceIDstr] = DeviceData(deviceIDstr, thisName, thisType, scanDateTimes[0]);
      updateList = true;
    }
    else{ //-----MAYBE Update Device
      bool matchingName = allDevicesFound[deviceIDstr].name != thisName;
      if(matchingName == false){
        allDevicesFound[deviceIDstr].name = thisName;
        updateList = true;
      }
      //ELSE... name update not required [expected]

      bool matchingType = allDevicesFound[deviceIDstr].type != thisType;
      if(matchingType == false){
        allDevicesFound[deviceIDstr].type = thisType;
        updateList = true;
      }
      //ELSE... type update not required [expected]
    }

    //-----Update Device Values
    //NOTE: our scanresults list DOES NOT CLEAR 
    //so if a device disconnects we will just have the last recieved RSSI
    var newRSSI = scanResults[deviceID].rssi;
    allDevicesFound[deviceIDstr].add(newRSSI);

    //-----Update Our Main List
    if(updateList) setState(() {});
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