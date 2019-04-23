import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';

class NewDeviceTile extends StatelessWidget {
  final List<DateTime> scanDateTimes;
  final Map<String, DeviceData> devices;
  final DeviceData device;

  NewDeviceTile({
    @required this.scanDateTimes,
    @required this.devices,
    @required this.device,
  });

  @override
  Widget build(BuildContext context) {
    var name = device.name.toString();
    bool noName = (name == "");
    var id = device.id.toString();
    var type = shortBDT(device.type);

    return InkWell(
      onTap: (){
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      FontAwesomeIcons.solidHeart,
                      color: Colors.redAccent, //Navigation.blueGrey, //Colors.redAccent,
                      size: 45,
                    ),
                  ),
                  Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        child: new Text(
                        "120",
                        style: TextStyle(
                          color: Colors.white,
                          shadows: textStroke(.25, Colors.black)
                        ),
                    ),
                      ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      noName ? "No Name Available" : name,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18,
                      ),
                    ),
                    new Text(id + " | " + type),
                    new Text("Last Pulse: " + durationPrint(Duration(milliseconds: 542)) + " ago"),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}