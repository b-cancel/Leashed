import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/addNew.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';
import 'package:page_transition/page_transition.dart';

class NewDeviceTile extends StatelessWidget {
  final Map<String, DeviceData> devices;
  final DeviceData device;

  NewDeviceTile({
    @required this.devices,
    @required this.device,
  });

  @override
  Widget build(BuildContext context) {
    var name = device.name.toString();
    bool noName = (name == "");
    var id = device.id.toString();
    var type = shortBDT(device.type);

    //TODO... add inkwell or gesture detector with print... see performance difference
    return InkWell(
      onTap: (){
        Navigator.push(context, PageTransition(
          type: PageTransitionType.fade,
          duration: Duration.zero, 
          child: AddNew(
            name: name,
            id: id,
            type: type,
          ),
        ));
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SignalPulse(
                    interval: Duration(milliseconds: 100),
                    scanData: device.scanData,
                  ),
                  Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        child: CurrentRSSI(
                          interval: Duration(milliseconds: 500),
                          scanData: device.scanData,
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
                    new TimeSince(
                      interval: Duration(milliseconds: 500),
                      scanData: device.scanData,
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

//------------------------------Widgets We Pass To Auto Updater

class TimeSince extends StatefulWidget {
  final ScanData scanData;
  final Duration interval;

  TimeSince({
    @required this.scanData,
    this.interval: const Duration(milliseconds: 250),
  });

  @override
  _TimeSinceState createState() => _TimeSinceState();
}

class _TimeSinceState extends State<TimeSince> {
  void update() async{
    await Future.delayed(widget.interval);
    if(mounted){
      setState(() {});
      update();
    }
  }

  @override
  void initState() {
    update(); //start cyclical update
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime lastScan = widget.scanData.rssiUpdateDateTimes.last;
    Duration timeSince = (DateTime.now()).difference(lastScan);

    //round to the nearest second, its really annoying to see milliseconds
    timeSince = (timeSince < Duration(seconds: 1)) ? Duration(seconds: 1) : timeSince;

    return new Text("Last Pulse: " + durationPrint(timeSince) + " ago");
  }
}

class CurrentRSSI extends StatefulWidget {
  final ScanData scanData;
  final int valuesPerAverage;
  final Duration interval;

  CurrentRSSI({
    @required this.scanData,
    this.valuesPerAverage: 7,
    this.interval: const Duration(milliseconds: 250),
  });

  @override
  _CurrentRSSIState createState() => _CurrentRSSIState();
}

class _CurrentRSSIState extends State<CurrentRSSI> {
  void update() async{
    await Future.delayed(widget.interval);
    if(mounted){
      setState(() {});
      update();
    }
  }

  @override
  void initState() {
    update(); //start cyclical update
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int lastIndex = widget.scanData.rssiUpdates.length - 1;
    num lastAverageRSSI = getAverage(widget.scanData.rssiUpdates, lastIndex, widget.valuesPerAverage);
    int signalStrength = rssiToAdjustedRssi(lastAverageRSSI).toInt();

    return new Text(
      signalStrength.toString(),
      style: TextStyle(
        color: Colors.white,
        shadows: textStroke(.25, Colors.black)
      ),
    );
  }
}

class SignalPulse extends StatefulWidget {
  final ScanData scanData;
  final Duration interval;

  SignalPulse({
    @required this.scanData,
    this.interval: const Duration(milliseconds: 250),
  });

  @override
  _SignalPulseState createState() => _SignalPulseState();
}

class _SignalPulseState extends State<SignalPulse> {
  void update() async{
    await Future.delayed(widget.interval);
    if(mounted){
      setState(() {});
      update();
    }
  }

  @override
  void initState() {
    update(); //start cyclical update
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //NOTE: we use min so the scanner being off doesn't throw off what should be our average
    Duration minDuration = widget.scanData.minIntervalDuration ?? Duration(milliseconds: 100);
    Duration averageInterval = minDuration * 3;
    averageInterval = (averageInterval == null) ? Duration(seconds: 1) : averageInterval;

    DateTime lastScan = widget.scanData.rssiUpdateDateTimes.last;
    Duration intervalSoFar = (DateTime.now()).difference(lastScan);

    //0 -> averageInterval
    //0 -> 1
    Duration sub = averageInterval - intervalSoFar;
    double float = sub.inMicroseconds / averageInterval.inMicroseconds;

    //float affect color
    Color heartColor;
    heartColor = Color.lerp(Navigation.blueGrey, Colors.redAccent, float);

    //float affect size
    double heartSize;
    heartSize = lerp(55, 45, float);

    return Container(
      width: 65,
      height: 65,
      child: Center(
        child: Icon(
          Icons.warning, //TODO... remove thing
          //FontAwesomeIcons.solidHeart,
          color: heartColor,
          size: heartSize,
        ),
      ),
    );
  }
}