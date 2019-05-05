import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/scanner.dart';
import 'package:system_setting/system_setting.dart';

class BluetoothOffBanner extends StatefulWidget {
  @override
  _BluetoothOffBannerState createState() => _BluetoothOffBannerState();
}

class _BluetoothOffBannerState extends State<BluetoothOffBanner> {
  @override
  void initState() {
    super.initState();

    ScannerStaticVars.bluetoothState.addListener((){
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    BluetoothState bleState = ScannerStaticVars.getBluetoothState();
    String bleStateString = "";
    if(bleState == BluetoothState.turningOn) bleStateString = "Turning On";
    else if(bleState == BluetoothState.turningOff) bleStateString = "Turning Off";
    else{
      bleStateString = bleState.toString().substring(15);
      bleStateString = bleStateString[0].toUpperCase() + bleStateString.substring(1);
    }

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
            new Text(
              ' The Bluetooth Adapter Is ' + bleStateString,
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

/*
// create an async void to call the API function with settings name as parameter
openSettingsMenu(settingsName) async {
    var resultSettingsOpening = false;

    try {
      resultSettingsOpening =
          await AccessSettingsMenu.openSettings(settingsType: settingsName);
    } catch (e) {
      resultSettingsOpening = false;
    }
}
*/