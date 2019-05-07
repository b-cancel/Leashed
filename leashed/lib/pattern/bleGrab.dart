import 'package:flutter/material.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/pattern/blePattern.dart';
import 'package:leashed/widgets/instruction.dart';
import 'package:page_transition/page_transition.dart';

class BleGrab extends StatelessWidget {
  Widget build(BuildContext context) {
    return Instruction(
      imageUrl: "assets/pngs/holdBle.png",
      lines: ["Grab Your", "Bluetooth Device"],
      onDone: (){
        Navigator.pushReplacement(context, PageTransition(
          type: PageTransitionType.fade,
          duration: Duration.zero,
          child: BlePatternPage(
            secondsPerStep: Navigation.timeToDetectPattern.value,
          ),
        ));
      },
    );
  }
}