import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';

class NewDeviceTile extends StatelessWidget {
  final BuildContext scaffoldContext;
  final List<DateTime> scanDateTimes;
  final List<DateTime> tapDateTimes;
  final Map<String, DeviceData> devices;
  final DeviceData device;
  final bool updatedThisFrame;

  NewDeviceTile({
    @required this.scaffoldContext,
    @required this.scanDateTimes,
    @required this.tapDateTimes,
    @required this.devices,
    @required this.device,
    @required this.updatedThisFrame,
  });

  @override
  Widget build(BuildContext context) {
    var name = device.name.toString();
    bool nameNotFound = (name == "" || name == null);
    var id = device.id.toString();
    //unknown, classic, le, dual
    var type = (device.type != BluetoothDeviceType.unknown) ? device.type.toString() : "?";

    //updated every frame
    var rssi = device.scanData.rssiUpdates.last;
    Duration waitTimeSoFar = (DateTime.now()).difference(device.scanData.rssiUpdateDateTimes.last);

    return InkWell(
      onTap: (){
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                child: Icon(
                  FontAwesomeIcons.solidHeart,
                  color: Colors.red,
                  size: 35,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      nameNotFound ? "NO NAME" : name,
                      style: TextStyle(
                        color: nameNotFound ? Colors.black : Colors.blue,
                        fontSize: nameNotFound ? 12 : 22,
                      ),
                    ),
                    new Text(id),
                    new Text(type),
                    new Text("Samples: " + device.scanData.rssiUpdates.length.toString()),
                  ],
                ),
              ),
              /*
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      (updatedThisFrame) ? new Text("*RSSI") : new Text("RSSI"),
                      new Text(rssi.toString()),
                      new Text("Waiting For"),
                      new Text(durationPrint(waitTimeSoFar)),
                    ],
                  ),
                ),
              ),
              */
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}