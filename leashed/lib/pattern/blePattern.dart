import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/widgets/instruction.dart';

class BlePattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Instruction(
      imageUrl: "assets/pngs/bleLeftTurn.png",
      lines: ["Hold Your Device", "To The Left", "Of Your Phone"],
      onDone: (){
        print("pattern running");
      },
    );
  }
}