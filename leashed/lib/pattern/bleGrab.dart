import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/pattern/blePattern.dart';
import 'package:leashed/widgets/instruction.dart';
import 'package:page_transition/page_transition.dart';

class BleGrab extends StatelessWidget {
  final Map<String, DeviceData> allDevicesFound;
  final List<DateTime> scanDateTimes;

  BleGrab({
    @required this.allDevicesFound,
    @required this.scanDateTimes,
  });

  Widget build(BuildContext context) {
    return Instruction(
      allDevicesFound: allDevicesFound,
      scanDateTimes: scanDateTimes,
      imageUrl: "assets/pngs/holdBle.png",
      lines: ["Grab Your", "Bluetooth Device"],
      onDone: (){
        Navigator.pushReplacement(context, PageTransition(
          type: PageTransitionType.fade,
          duration: Duration.zero, 
          child: BlePattern(
            allDevicesFound: allDevicesFound,
            scanDateTimes: scanDateTimes,
          ),
        ));
      },
    );
  }
}