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
                  AutoUpdatingWidget(
                    child: SignalPulse(
                      scanData: device.scanData,
                    ),
                  ),
                  Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        child: new AutoUpdatingWidget(
                          child: CurrentRSSI(
                            scanData: device.scanData,
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
                    new AutoUpdatingWidget(
                      child: TimeSince(scanData: device.scanData),
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

class AutoUpdatingWidget extends StatefulWidget {
  final Widget child;
  final Duration interval;

  AutoUpdatingWidget({
    @required this.child,
    this.interval: const Duration(milliseconds: 250),
  });

  @override
  _AutoUpdatingWidgetState createState() => _AutoUpdatingWidgetState();
}

class _AutoUpdatingWidgetState extends State<AutoUpdatingWidget> {
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
    return widget.child;
  }
}

//------------------------------Widgets We Pass To Auto Updater

class TimeSince extends StatelessWidget {
  final ScanData scanData;

  TimeSince({
    this.scanData,
  });

  @override
  Widget build(BuildContext context) {
    DateTime lastScan = scanData.rssiUpdateDateTimes.last;
    Duration timeSince = (DateTime.now()).difference(lastScan);

    return new Text("Last Pulse: " + durationPrint(timeSince) + " ago");
  }
}

class CurrentRSSI extends StatelessWidget {
  final ScanData scanData;
  final int valuesPerAverage;

  CurrentRSSI({
    this.scanData,
    this.valuesPerAverage: 7,
  });

  @override
  Widget build(BuildContext context) {
    int lastIndex = scanData.rssiUpdates.length - 1;
    num lastAverageRSSI = getAverage(scanData.rssiUpdates, lastIndex, valuesPerAverage);
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

class SignalPulse extends StatelessWidget {
  final ScanData scanData;

  SignalPulse({
    this.scanData,
  });

  @override
  Widget build(BuildContext context) {
    Duration averageInterval = scanData.averageIntervalDuration;
    averageInterval = (averageInterval == null) ? Duration(seconds: 1) : averageInterval;

    DateTime lastScan = scanData.rssiUpdateDateTimes.last;
    Duration intervalSoFar = (DateTime.now()).difference(lastScan);

    //0 -> averageInterval
    //0 -> 1
    Duration sub = averageInterval - intervalSoFar;
    double float = sub.inMicroseconds / averageInterval.inMicroseconds;

    //float affect color
    Color heartColor;
    heartColor = Color.lerp(Colors.black, Colors.redAccent, float);

    //float affect size
    double heartSize;
    heartSize = lerp(55, 45, float);

    return Container(
      width: 65,
      height: 65,
      child: Center(
        child: Icon(
          FontAwesomeIcons.solidHeart,
          color: heartColor,
          size: heartSize,
        ),
      ),
    );
  }
}