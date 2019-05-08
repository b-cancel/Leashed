import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/data.dart';
import 'navigation.dart';

//the line that runs the application
void main() {
  //Force App Into Portrait Mode [there is no reason why you would use this in another way]
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  //start up the app
  asyncMain();
}

//NOTE: we do this to ensure that we load up the data BEFORE starting up the app
void asyncMain()async{
  await DataManager.init();
  runApp(Navigation());
}