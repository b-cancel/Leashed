import 'package:charts_common/common.dart';
import 'package:flutter/material.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;

//NOTE: for full screen scaner this handles tellin the user that the scanner is turning on

class DeviceScanner extends StatefulWidget {
  final String deviceID;
  final Widget child;
  final String title;

  const DeviceScanner({
    this.deviceID,  
    this.child,
    this.title,
  });

  @override
  _DeviceScannerState createState() => _DeviceScannerState();
}

class _DeviceScannerState extends State<DeviceScanner> {
  @override
  void initState() {
    //super init
    super.initState();

    //start the scanner after the first build (the user will instantly see the effect of them pressing the plus)
    WidgetsBinding.instance.addPostFrameCallback((_) => ScannerStaticVars.startScan());

    //Listeners To Determine When to Reload
    ScannerStaticVars.bluetoothOn.addListener(customExit); //travels away on turn off
    ScannerStaticVars.isScanning.addListener(customSetState); //allow for indicator that turned on
    ScannerStaticVars.wantToBeScanning.addListener(customSetState); //allows for reset button
  }

  @override
  void dispose(){
    //remove listeners
    ScannerStaticVars.bluetoothOn.removeListener(customExit); //travels away on turn off
    ScannerStaticVars.isScanning.removeListener(customSetState); //allow for indicator that turned on
    ScannerStaticVars.wantToBeScanning.removeListener(customSetState); //allows for reset button

    //stop the scanner
    ScannerStaticVars.stopScan();

    //super dispose
    super.dispose();
  }

  //-----BLE Interact START

  customSetState() async {
    if(mounted){
      setState((){});
    }
  }

  customExit() async{
    ScannerStaticVars.stopScan();
    Navigator.of(context).maybePop();
  }

  //-----BLE Interact END

  ///-------------------------Overrides-------------------------
  @override
  Widget build(BuildContext context) {
    //our main widget to return
    return new Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => customExit(),
          child: IgnorePointer(
            child: BackButton(),
          ),
        ),
        title: new Text(
          widget.title,
        ),
      ),
      body: new Builder(builder: (BuildContext context) {
        if(ScannerStaticVars.isScanning.value){
          return Container(
            child: widget.child,
          );
        }
        else{
          return InkWell(
            onTap: (){
              //Inform the user that it might fail
              final SnackBar msg = SnackBar(
                content: Text(
                  'Trying To Re-Start The Scanner' 
                  + '\n' 
                  + 'If It Fails Please Try Again',
                ),
              );
              Scaffold.of(context).showSnackBar(msg);
              //Attempt to Start Up The Scanner
              ScannerStaticVars.startScan();
            },
            child: Container(
              child: Center(
                child: new Text("waiting for scanner to turn on"),
              ),
            ),
          );
        }
      }),
    );
  }
}