import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/pattern/phoneDown.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:leashed/widgets/newDeviceTile.dart';
import 'package:page_transition/page_transition.dart';
import 'scanner.dart';

//NOTE: in order to be able to handle large quantity of devices
//1. we only update the main list if a new device is added

//In order to give live updates of pulse and things relating to it
//1. the heart is in its own seperate widget updating at a particular rate
//---the heart beat is only as long as the fastest update (or some number?)
//2. the last seen updates as often as [1]

class SearchNew extends StatefulWidget {
  @override
  _SearchNewState createState() => _SearchNewState();
}

class _SearchNewState extends State<SearchNew> {
  List<String> deviceIDs;

  @override
  void initState() {
    super.initState();

    //Listeners To Determine Reload

    print("list init");
    ScannerStaticVars.allDevicesfoundLength.addListener(() async{
      deviceIDs = await sortResults(); 
      setState((){});
    });

    ScannerStaticVars.bluetoothOn.addListener((){
      setState((){});
    });

    ScannerStaticVars.isScanning.addListener((){
      setState((){});
    });

    ScannerStaticVars.showManualRestartButton.addListener((){
      setState((){});
    });

    deviceIDs = new List<String>();
    deviceIDs.addAll(ScannerStaticVars.allDevicesFound.keys.toList());
  }

  ///-------------------------Overrides-------------------------
  @override
  Widget build(BuildContext context) {
    int deviceCount = ScannerStaticVars.allDevicesfoundLength.value;
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
          (ScannerStaticVars.bluetoothOn.value)
          ? Container()
          : new BluetoothOffBanner(),
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.black
            ),
            child: Expanded(
              //maybe not nested listview?
              //maybe ignore pointer in all locations except what is expected
              //maybe dont reload tile hearts, rssi, and times that we dont need to
              //gesture detector instead of inkwell
              //flutter run --release
              //physics: const AlwaysScrollableScrollPhysics(),
              //slivers are slower for tons of objects
              child: ListView(
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(8.0),
                    itemCount: deviceIDs.length,
                    itemBuilder: (BuildContext context, int index) {
                      String deviceID = deviceIDs[index];
                      DeviceData device = ScannerStaticVars.allDevicesFound[deviceID];
                      return NewDeviceTile(
                        scanDateTimes: ScannerStaticVars.scanDateTimes,
                        devices: ScannerStaticVars.allDevicesFound,
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
      floatingActionButton: (ScannerStaticVars.showManualRestartButton.value)
      ? FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.black,
        onPressed: (){
          ScannerStaticVars.startScan();
        },
        icon: new Icon(Icons.refresh),
        label: new Text("Re-Start Scan"),
      )
      : (ScannerStaticVars.bluetoothOn.value && ScannerStaticVars.isScanning.value)
      ? FloatingActionButton.extended(
        onPressed: (){
          Navigator.push(context, PageTransition(
            type: PageTransitionType.fade,
            duration: Duration.zero, 
            child: PhoneDown(),
          ));
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
      ) : Container(),
    );
  }
}