import 'package:flutter/material.dart';

import 'navigation.dart';

//the line that runs the application
void main() {
  //Force App Into Portrait Mode [there is no reason why you would use this in another way]
  /*
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  */

  //Run our App
  runApp(Navigation());
}