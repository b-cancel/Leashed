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
                    child: new AutoUpdatingHeart(
                      device: device,
                    ),
                  ),
                  Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        child: new AutoUpdatingRSSI(
                          device: device,
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
                    new AutoUpdatingTimeSince(
                      device: device,
                    ),
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

class AutoUpdatingTimeSince extends StatefulWidget {
  final DeviceData device;
  final Duration interval;

  const AutoUpdatingTimeSince({
    this.device,
    this.interval: const Duration(milliseconds: 250),
  });

  @override
  _AutoUpdatingTimeSinceState createState() => _AutoUpdatingTimeSinceState();
}

class _AutoUpdatingTimeSinceState extends State<AutoUpdatingTimeSince> {
  @override
  void initState() {
    update(); //start cyclical update
    super.initState();
  }

  void update() async{
    await Future.delayed(widget.interval);
    if(mounted){
      setState(() {});
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime lastScan = widget.device.scanData.rssiUpdateDateTimes.last;
    Duration timeSince = (DateTime.now()).difference(lastScan);

    return new Text("Last Pulse: " + durationPrint(timeSince) + " ago");
  }
}

class AutoUpdatingRSSI extends StatefulWidget {
  final DeviceData device;
  final Duration interval;

  const AutoUpdatingRSSI({
    this.device,
    this.interval: const Duration(milliseconds: 250),
  });

  @override
  _AutoUpdatingRSSIState createState() => _AutoUpdatingRSSIState();
}

class _AutoUpdatingRSSIState extends State<AutoUpdatingRSSI> {
  @override
  void initState() {
    update(); //start cyclical update
    super.initState();
  }

  void update() async{
    await Future.delayed(widget.interval);
    if(mounted){
      setState(() {});
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    int lastRSSI = widget.device.scanData.rssiUpdates.last;
    int signalStrength = rssiToAdjustedRssi(lastRSSI);

    return new Text(
      signalStrength.toString(),
      style: TextStyle(
        color: Colors.white,
        shadows: textStroke(.25, Colors.black)
      ),
    );
  }
}

class AutoUpdatingHeart extends StatefulWidget {
  final DeviceData device;
  final Duration interval;

  const AutoUpdatingHeart({
    this.device,
    this.interval: const Duration(milliseconds: 250),
  });

  @override
  _AutoUpdatingHeartState createState() => _AutoUpdatingHeartState();
}

class _AutoUpdatingHeartState extends State<AutoUpdatingHeart> {
  @override
  void initState() {
    update(); //start cyclical update
    super.initState();
  }

  void update() async{
    await Future.delayed(widget.interval);
    if(mounted){
      setState(() {});
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    Duration averageInterval = widget.device.scanData.averageIntervalDuration;

    DateTime lastScan = widget.device.scanData.rssiUpdateDateTimes.last;
    Duration timeSince = (DateTime.now()).difference(lastScan);

    //if timeSince == averageInterval => Navigation.blueGrey
    //else Navigation.redAccent

    return Icon(
      FontAwesomeIcons.solidHeart,
      color: Color.lerp(Colors.redAccent, Navigation.blueGrey, .5),
      size: 45,
    );
  }
}