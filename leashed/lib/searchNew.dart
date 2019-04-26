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

    //start off the device ID list
    deviceIDs = ScannerStaticVars.allDevicesFound.keys.toList();

    //start the scanner after the first build (the user will instantly see the effect of them pressing the plus)
    WidgetsBinding.instance.addPostFrameCallback((_) => ScannerStaticVars.startScan());

    //Listeners To Determine When to Reload
    ScannerStaticVars.allDevicesfoundLength.addListener(updateListThenSetState);
    ScannerStaticVars.bluetoothOn.addListener(customSetState);
    ScannerStaticVars.isScanning.addListener(customSetState);
    ScannerStaticVars.showManualRestartButton.addListener(customSetState);
  }

  @override
  void dispose(){
    super.dispose();
    ScannerStaticVars.allDevicesfoundLength.removeListener(updateListThenSetState);
    ScannerStaticVars.bluetoothOn.removeListener(customSetState);
    ScannerStaticVars.isScanning.removeListener(customSetState);
    ScannerStaticVars.showManualRestartButton.removeListener(customSetState);
    ScannerStaticVars.stopScan();
  }

  updateListThenSetState(){
    customSetState(updateList: true);
  }

  customSetState({bool updateList: false})async {
    if(updateList){
      deviceIDs = await ScannerStaticVars.sortResults(); 
    }
    if(mounted){
      setState((){});
    }
  }

  ///-------------------------Overrides-------------------------
  @override
  Widget build(BuildContext context) {
    int deviceCount = deviceIDs.length;
    String singularOrPlural = (deviceCount == 1) ? "Device" : "Devices";

    //our main widget to return
    return new Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () async{
            ScannerStaticVars.stopScan();
            Navigator.of(context).maybePop();
          },
          child: IgnorePointer(
            child: BackButton(),
          ),
        ),
        title: new Text(
          deviceCount.toString() + ' ' + singularOrPlural + ' Found',
        ),
      ),
      body: new Column(
        children: <Widget>[
          (ScannerStaticVars.bluetoothOn.value)
          ? Container()
          : new BluetoothOffBanner(),
          new RaisedButton(
            onPressed: () => ScannerStaticVars.scannerStatus(),
            child: new Text("debug"),
          ),
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.black
            ),
            child: Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    ScannerStaticVars.stopScan();
                  } else if (scrollNotification is ScrollEndNotification) {
                    ScannerStaticVars.startScan();
                  }
                },
                child: ListView.builder(
                  //POTENTIAL OPTIMIZATIONS
                  //maybe ignore pointer in all locations except what is expected
                  //gesture detector instead of inkwell
                  //flutter run --release
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(8.0),
                  itemCount: deviceIDs.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if(index == deviceIDs.length){
                      return new Container(
                        height: 65,
                      );
                    }
                    else{
                      String deviceID = deviceIDs[index];
                      DeviceData device = ScannerStaticVars.allDevicesFound[deviceID];
                      return NewDeviceTile(
                        devices: ScannerStaticVars.allDevicesFound,
                        device: device,
                      );
                    }
                  },
                ),
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