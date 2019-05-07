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

    //travels away from this widget when the user turns the bluetooth off
    //turns on the scanner when the user turns bluetooth on
    ScannerStaticVars.bluetoothOn.addListener(navigationAwayIfTurnedOff);

    //show the user what they need to do to get things working (turn on OR wait)
    ScannerStaticVars.bluetoothOn.addListener(customSetState); //show that you need to turn bluetooth on
    ScannerStaticVars.isScanning.addListener(customSetState); //show that the scanner is turning on

    //start the scan ONLY if the bluetooth is already on
    if(ScannerStaticVars.bluetoothOn.value){
      //start the scanner after the first build 
      //the user will instantly see the effect of them pressing the plus
      startScanner();
    }
  }

  @override
  void dispose(){
    //stop the scanner
    ScannerStaticVars.stopScan();

    //travels away from this widget when the user turns the bluetooth off
    //turns on the scanner when the user turns bluetooth on
    ScannerStaticVars.bluetoothOn.removeListener(navigationAwayIfTurnedOff);

    //show the user what they need to do to get things working (turn on OR wait)
    ScannerStaticVars.bluetoothOn.removeListener(customSetState); //show that you need to turn bluetooth on
    ScannerStaticVars.isScanning.removeListener(customSetState); //show that the scanner is turning on

    //super dispose
    super.dispose();
  }

  //-----Listeners START

  customSetState(){
    if(mounted){
      setState((){});
    }
  }

  navigationAwayIfTurnedOff() async{
    if(ScannerStaticVars.bluetoothOn.value){
      startScanner();
    }
    else{
      ScannerStaticVars.stopScan();
      Navigator.of(context).maybePop();
    }
  }

  startScanner(){
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ScannerStaticVars.startScan(),
    );
  }

  //-----Listeners END

  @override
  Widget build(BuildContext context) {
    if(ScannerStaticVars.bluetoothOn.value){
      if(ScannerStaticVars.isScanning.value){
        return widget.child;
      }
      else{
        return new Builder(
          builder: (BuildContext context) {
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
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Please Wait',
                          style: TextStyle(
                            fontSize: 48,
                          ),
                        ),
                        Container(
                          height: 8,
                        ),
                        Image.asset(
                          "assets/pngs/hourglass.png",
                          width: 150,
                        ),
                        Container(
                          height: 8,
                        ),
                        Text(
                          "For The Bluetooth Scanner",
                        ),
                        Text(
                          "To Start Up",
                        ),
                      ],
                    ),
                  ),
                )
              ),
            );
          }
        );
      }
    }
    else{
      return BluetoothOff(
        bluetoothOffWidget: BluetoothOffWidget.page,
      );
    }
  }
}