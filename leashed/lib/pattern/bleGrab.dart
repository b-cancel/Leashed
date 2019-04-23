import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/widgets/instruction.dart';

class BleGrab extends StatelessWidget {
Widget build(BuildContext context) {
    return Instruction(
      imageUrl: "assets/pngs/holdBle.png",
      lines: ["Grab Your", "Bluetooth Device"],
      onDone: (){
        Navigation.appRouter.navigateTo(
          context, 
          "blePattern", 
          transitionDuration: Duration.zero,
          replace: true,
        );
      },
    );
  }
}