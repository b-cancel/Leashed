import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/widgets/instruction.dart';

class PhoneDown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Instruction(
      imageUrl: "assets/gifs/final/phoneOnTable.gif",
      lines: ["Place Your Phone", "On A Flat Surface"],
      onDone: (){
        Navigation.appRouter.navigateTo(
          context, 
          "bleGrab", 
          transitionDuration: Duration.zero,
          replace: true,
        );
      },
    );
  }
}