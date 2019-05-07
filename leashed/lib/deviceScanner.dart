import 'package:flutter/material.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';

//This Widget
//IF the bluetooth if OFF -> asks user to turn it on
//IF the bluetooth is ON
//  1. automatically starts the scanner and then goes to the next page
//  2. exits the scanner if the user turns off the bluetooth
//    IF the user turns off bluetooth AFTER the scanner has started
//    which would indicate an ultimate troll
class ScanStarter extends StatefulWidget {
  final Widget child;

  const ScanStarter({
    this.child,
  });

  @override
  _ScanStarterState createState() => _ScanStarterState();
}

class _ScanStarterState extends State<ScanStarter>{
  @override
  void initState() {
    //super init
    super.initState();

    //Listeners To Determine When to Reload
    ScannerStaticVars.bluetoothOn.addListener(navigationAwayIfTurnedOff); //travels away on turn off
    ScannerStaticVars.isScanning.addListener(customSetState); //allow for indicator that turned on
    ScannerStaticVars.wantToBeScanning.addListener(customSetState); //allows for reset button

    //start the scan ONLY if the bluetooth is already on
    if(ScannerStaticVars.bluetoothOn.value){
      //start the scanner after the first build 
      //the user will instantly see the effect of them pressing the plus
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ScannerStaticVars.startScan(),
      );
    }
  }

  @override
  void dispose(){
    //stop the scanner
    ScannerStaticVars.stopScan();

    //remove listeners
    ScannerStaticVars.bluetoothOn.removeListener(navigationAwayIfTurnedOff); //travels away on turn off
    ScannerStaticVars.isScanning.removeListener(customSetState); //allow for indicator that turned on
    ScannerStaticVars.wantToBeScanning.removeListener(customSetState); //allows for reset button

    //super dispose
    super.dispose();
  }

  //-----BLE Interact START

  customSetState(){
    if(mounted){
      setState((){});
    }
  }

  navigationAwayIfTurnedOff() async{
    if(ScannerStaticVars.bluetoothOn.value == false){
      ScannerStaticVars.stopScan();
      Navigator.of(context).maybePop();
    }
  }

  //-----BLE Interact END

  @override
  Widget build(BuildContext context) {
    if(ScannerStaticVars.bluetoothOn.value){
      return new Builder(
        builder: (BuildContext context) {
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
        }
      );
    }
    else{
      return BluetoothOff(
        bluetoothOffWidget: BluetoothOffWidget.page,
      );
    }
  }
}