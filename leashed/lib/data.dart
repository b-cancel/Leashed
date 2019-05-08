import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class DataManager {
  static String _fileName = "leashedAppData.txt";
  static String _filePath;
  static File _fileReference;
  static String _fileString;
  static AppData appData; //accessible by all other functions

  static init() async{
    //get references to the file
    _filePath = await _localFilePath;
    
    //create or read the file
    _fileReference = File(_filePath);
    if(_fileExists == false){
      //create the file
      await _createFile;
      //fill our structs with defaults
      await _writeStructWithDefaults;
      //save the defaults on in the file
      await _writeStructToFile;
    }
    else{
      //read the file into struct
      await _writeFileToStruct;
    }
  }

  static bool get _fileExists{
    return FileSystemEntity.typeSync(_filePath) != FileSystemEntityType.notFound;
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> get _localFilePath async{
    final localPath = await _localPath;
    return '$localPath/$_fileName';
  }
  
  static get _createFile async{
    await _fileReference.create();
  }
  
  static get _writeStructWithDefaults async{
    appData = AppData.defaultData; //TODO... currently here
  }

  static get _writeStructToFile async{
    //convert Struct to String
    _fileString = appData.toJson.toString();
    //write file
    await _fileReference.writeAsString(_fileString);
  }

  static get _writeFileToStruct async{
    //read file
    _fileString = await _fileReference.readAsString();
    //convert String to Struct
    appData = AppData.toStruct(_fileString);
  }
}

//-------------------------STRUCT-------------------------

class AppData{
  SettingsStorage settingData;
  //LocationsStorage locationData;
  //List<DeviceStorage> deviceData;

  AppData(){

  }

  Map get toJson { 
    Map map = new Map();
    return map;
  }  

  //-------------------------Static Functions
  
  static AppData toStruct(String fileString){

  }

  static AppData get defaultData{

  }
}

class SettingsStorage{
  ColorSetting redSetting;
  ColorSetting yellowSetting;
  ColorSetting greenSetting;
  String sosMessage;
  List<SosContact> sosContacts;

  SettingsStorage(){

  }

  Map get toJson { 
    Map map = new Map();
    return map;
  }

  //-------------------------Static Functions
  
  static SettingsStorage toStruct(String fileString){

  }

  static SettingsStorage get defaultData{

  }
}

class ColorSetting{
  int checkDuration;
  int intervalDuration;

  ColorSetting(
    int checkDuration,
    int intervalDuration,
  ){
    this.checkDuration = checkDuration;
    this.intervalDuration = intervalDuration;
  }
  
  Map get toJson { 
    Map map = new Map();
    return map;
  }

  //-------------------------Static Functions
  
  static ColorSetting toStruct(String fileString){

  }

  static ColorSetting get defaultData{

  }
}

class SosContact{
  String name;
  String label;
  String number;

  SosContact(
    String name, 
    String label, 
    String number,
  ){
    this.name = name;
    this.label = label;
    this.number = number;
  }
    
  Map get toJson { 
    Map map = new Map();
    return map;
  }

  //-------------------------Static Functions
  
  static SosContact toStruct(String fileString){

  }

  static SosContact get defaultData{

  }
}

/*
//NOTE: from (1)Bluetooth (2)GPS
//1. I need to be able to access the location from the dateTime [constantly time]
//2. I need have a dynamic data structure

//1. we are using a Queues so that we can keep a max of X items efficiently
//2. this is because we dont really need constant time access
//3. we need to be able to add to the back
//4. we need to be able to remove from the front
//5. the keys Queue in both can return an index 
//    -that can then be used to find the item in another queue

//NOTE: because Device Storage uses LocationStorage keys to keep track of their location history
//we DO NOT remove any location marked as being used by Devices
class LocationsStorage{
  //NOTE: we only add a new GPS update IF we get new GPS from the scanner
  //list of last couple gps updates (equivalent length)
  Queue<LocationStorage> locations;
  Queue<double> longitude;
  Queue<int> dateTimeUpdates;
  Queue<int> keys; //unique keys to things can address this location
  final int maxLocationUpdatesStored = 125;

  d(){
    latitude[1]
  }
}

class LocationStorage{
  double latitude;
  double longitude;
  int dateTimeUpdates; //microseconds from epoch
}

class DeviceStorage
{
  //set once and done
  String id;
  BluetoothDeviceType type;
  String friendlyName;

  //device settings
  String assignedName;
  String imageUrl;

  //NOTE: we only add a new rssi update IF we get new rssi from the scanner
  //list of last couple rssi updates (equivalent length)
  Queue<int> rssiUpdates;
  Queue<int> rssiDateTimeUpdates; //microseconds from epoch
  static final int maxRssiUpdates = 250;
  

  DeviceStorage({
    String id,
    BluetoothDeviceType type,
    String friendlyName,
  }){
    //params
    this.id = id;
    this.type = type;
    this.friendlyName = friendlyName;

    //defaults
    assignedName = friendlyName;
    imageUrl = "assets/pngs/devicePlaceholder.png";

    //rssi list inits
    List<int> rssiUpdates;
    List<int> rssiDateTimeUpdates;

    //location list inits
    List<double> locationLatitude;
    List<double> locationLongitude;
    List<int> locationDateTimeUpdates;
  }

  Map toJson() { 
    Map map = new Map();
    map["id"] = id;
    map["Name"] = Name;
    return map;

    //set once and done
  String id;
  String type;
  String friendlyName;

  //device settings
  String assignedName;
  String imageUrl;

  //list of last couple rssi updates (equivalent length)
  List<int> rssiUpdates;
  List<int> rssiDateTimeUpdates;
  int maxRssiUpdates;

  //list of last couple gps update (equivalent length)
  List<double> locationLatitude;
  List<double> locationLongitude;
  List<int> locationDateTimeUpdates;
  int maxLocationUpdates;
  }  
}
*/