//Keep track of all the classes that keep track of all the data that can then be analyzed to locate a pattern
import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/utils.dart';

class DeviceData{
  //set once and done
  String id;
  String name; //MIGHT be blank
  BluetoothDeviceType type;

  DeviceData(String initID, String initName, BluetoothDeviceType initType, DateTime firstScan){
    id = initID;
    name = initName;
    type = initType;
  }
}