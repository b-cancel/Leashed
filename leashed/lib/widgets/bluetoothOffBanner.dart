import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:system_setting/system_setting.dart';

class BluetoothOffBanner extends StatelessWidget {
  const BluetoothOffBanner({
    Key key,
    @required this.bluetoothState,
  }) : super(key: key);

  final BluetoothState bluetoothState;

  @override
  Widget build(BuildContext context) {
    BluetoothState bleState = bluetoothState;
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
        color: Colors.redAccent,
        child: Row(
          children: <Widget>[
            new Icon(
              Icons.error,
              color: Theme.of(context).primaryTextTheme.subhead.color,
            ),
            new Text(
              'The Bluetooth Adapter Is ' + bleStateString,
              style: Theme.of(context).primaryTextTheme.subhead,
            ),
          ],
        ),
      ),
    );
  }
}