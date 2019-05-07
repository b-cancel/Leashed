import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/scanner.dart';
import 'package:system_setting/system_setting.dart';

enum BluetoothOffWidget {banner, page}

class BluetoothOff extends StatefulWidget {
  final BluetoothOffWidget bluetoothOffWidget;

  BluetoothOff({
    this.bluetoothOffWidget: BluetoothOffWidget.banner,
  });

  @override
  _BluetoothOffState createState() => _BluetoothOffState();
}

class _BluetoothOffState extends State<BluetoothOff> {
  @override
  void initState() {
    super.initState();
    ScannerStaticVars.bluetoothState.addListener(customSetState);
  }

  @override
  void dispose() { 
    ScannerStaticVars.bluetoothState.removeListener(customSetState);
    super.dispose();
  }

  customSetState(){
    if(mounted){
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    BluetoothState bluetoothState = ScannerStaticVars.getBluetoothState();
    String bluetoothStateString = bluetoothStateToString(bluetoothState);
    bool isBanner = widget.bluetoothOffWidget == BluetoothOffWidget.banner;

    return (isBanner)
    ? Banner(bluetoothStateString)
    : Page(bluetoothStateString);
  }
}

class Banner extends StatelessWidget {
  final String bluetoothStateString;
  Banner(this.bluetoothStateString);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        SystemSetting.goto(SettingTarget.BLUETOOTH);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        width: MediaQuery.of(context).size.width,
        color: Colors.red,
        child: Row(
          children: <Widget>[
            new Icon(
              Icons.error,
              color: Colors.black,
            ),
            Container(width: 4),
            new Text(
              'The Bluetooth Adapter Is ' + bluetoothStateString,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Page extends StatelessWidget {
  final String bluetoothStateString;
  Page(this.bluetoothStateString);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        SystemSetting.goto(SettingTarget.BLUETOOTH);
      },
      child: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  ' The Bluetooth Adapter Is ' + bluetoothStateString,
                ),
                Icon(
                  Icons.bluetooth_disabled,
                  size: 256,
                ),
                Text(
                  "This Feature Requires Bluetooth",
                ),
                Container(height: 4),
                Text(
                  "Please Tap Here To Turn It In On",
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}

String bluetoothStateToString(BluetoothState bluetoothState){
  String bluetoothStateString = "";
  if(bluetoothState == BluetoothState.turningOn) bluetoothStateString = "Turning On";
  else if(bluetoothState == BluetoothState.turningOff) bluetoothStateString = "Turning Off";
  else{
    bluetoothStateString = bluetoothState.toString().substring(15);
    bluetoothStateString = bluetoothStateString[0].toUpperCase() + bluetoothStateString.substring(1);
  }
  return bluetoothStateString;
}