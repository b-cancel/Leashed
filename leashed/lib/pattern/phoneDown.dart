import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/pattern/bleGrab.dart';
import 'package:leashed/widgets/instruction.dart';
import 'package:page_transition/page_transition.dart';

class PhoneDown extends StatelessWidget {
  final Map<String, DeviceData> allDevicesFound;
  final List<DateTime> scanDateTimes;

  PhoneDown({
    @required this.allDevicesFound,
    @required this.scanDateTimes,
  });

  @override
  Widget build(BuildContext context) {
    return Instruction(
      allDevicesFound: allDevicesFound,
      scanDateTimes: scanDateTimes,
      imageUrl: "assets/gifs/final/phoneOnTable.gif",
      lines: ["Place Your Phone", "On A Flat Surface"],
      onDone: (){
        Navigator.pushReplacement(context, PageTransition(
          type: PageTransitionType.fade,
          duration: Duration.zero, 
          child: BleGrab(
            allDevicesFound: allDevicesFound,
            scanDateTimes: scanDateTimes,
          ),
        ));
      },
    );
  }
}