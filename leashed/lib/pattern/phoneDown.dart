import 'package:flutter/material.dart';
import 'package:leashed/pattern/bleGrab.dart';
import 'package:leashed/widgets/instruction.dart';
import 'package:page_transition/page_transition.dart';

class PhoneDown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Instruction(
      imageUrl: "assets/gifs/final/phoneOnTable.gif",
      lines: ["Place Your Phone", "On A Flat Surface"],
      onDone: (){
        Navigator.pushReplacement(context, PageTransition(
          type: PageTransitionType.fade,
          duration: Duration.zero, 
          child: BleGrab(),
        ));
      },
    );
  }
}