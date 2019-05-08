import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

//NOTE: Search "MANUAL DEFAULT" To Find The Defaults I Selected

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

    //TODO... remove this line to write new data to file
    if(_fileExists) _deleteFile;

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

  static get _deleteFile async{
    await _fileReference.delete();
  }
  
  static get _writeStructWithDefaults async{
    appData = AppData.defaultData;
  }

  static get _writeStructToFile async{
    //convert Struct to String
    _fileString = json.encode(appData);
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

//-------------------------APP DATA-------------------------

class AppData{
  SettingsData settingsData;
  SosData sosData;
  List<DeviceData> deviceData;
  LocationsData locationData;

  AppData(
    this.settingsData,
    this.sosData,
    this.deviceData,
    this.locationData,
  );

  Map toJson(){ 
    Map map = new Map();
    map["settingsData"] = json.encode(settingsData);
    map["sosData"] = json.encode(sosData);
    map["deviceData"] = json.encode(deviceData);
    map["locationData"] = json.encode(locationData);
    return map;
  }

  //-------------------------Static Functions
  
  static AppData toStruct(String string){
    //TODO... fill this in
  }

  static AppData get defaultData{
    return AppData(
      SettingsData.defaultData,
      SosData.defaultData,
      new List<DeviceData>(),
      LocationsData.defaultData,
    );
  }
}

//-------------------------SETTINGS DATA-------------------------

class SettingsData{
  ColorSetting redSetting;
  ColorSetting yellowSetting;
  ColorSetting greenSetting;

  SettingsData(
    this.redSetting,
    this.yellowSetting,
    this.greenSetting,
  );

  Map toJson(){ 
    Map map = new Map();
    map["redSetting"] = json.encode(redSetting);
    map["yellowSetting"] = json.encode(yellowSetting);
    map["greenSetting"] = json.encode(greenSetting);
    return map;
  }

  //-------------------------Static Functions

  static SettingsData toStruct(String string){
    //TODO... fill this in
  }

  static SettingsData get defaultData{
    return SettingsData(
      ColorSetting.defaultRedData, 
      ColorSetting.defaultYellowData, 
      ColorSetting.defaultGreenData,
    );
  }
}

class ColorSetting{
  int checkDuration;
  int intervalDuration;

  ColorSetting(
    this.checkDuration,
    this.intervalDuration,
  );

  Map toJson(){ 
    Map map = new Map();
    map["checkDuration"] = json.encode(checkDuration);
    map["intervalDuration"] = json.encode(intervalDuration);
    return map;
  }
  
  //-------------------------Static Functions
  
  static ColorSetting toStruct(String string){
    //TODO... fill this in
  }

  static ColorSetting get defaultRedData{
    return ColorSetting(
      Duration(seconds: 5).inMicroseconds,
      Duration(seconds: 15).inMicroseconds,
    );
  }

  static ColorSetting get defaultYellowData{
    return ColorSetting(
      Duration(seconds: 30).inMicroseconds,
      Duration(minutes: 7, seconds: 30).inMicroseconds,
    );
  }

  static ColorSetting get defaultGreenData{
    return ColorSetting(
      Duration(minutes: 5).inMicroseconds,
      Duration(minutes: 15).inMicroseconds,
    );
  }
}

//-------------------------SOS DATA-------------------------

class SosData{
  String sosMessage;
  List<SosContact> sosContacts;

  SosData(
    this.sosMessage,
    this.sosContacts,
  );

  Map toJson(){ 
    Map map = new Map();
    map["sosMessage"] = json.encode(sosMessage);
    map["sosContacts"] = json.encode(sosContacts);
    return map;
  }
  
  //-------------------------Static Functions
  
  static SosData toStruct(String string){
    //TODO... fill this in
  }

  static SosData get defaultData{
    return SosData(
      "", //NOTE: this empty message tells the settings field to place the actual default in place 
      new List<SosContact>(), 
    );
  }
}

class SosContact{
  String name;
  String label;
  String number;

  SosContact(
    this.name,
    this.label,
    this.number,
  );

  Map toJson(){ 
    Map map = new Map();
    map["name"] = json.encode(name);
    map["label"] = json.encode(label);
    map["number"] = json.encode(number);
    return map;
  }

  //-------------------------Static Functions
  
  static SosContact toStruct(String string){
    //TODO... fill this in
  }

  //NOTE: has no default(would be added manually)
}

//-------------------------LOCATION AND GPS-------------------------

//NOTE: from (1)Bluetooth (2)GPS
//1. I need to be able to access the location from the dateTime [constantly time]
//2. I need have a dynamic data structure that can easily grow and shrink

//-------------------------DEVICE DATA-------------------------

class DeviceData{
  //set once and done
  String id;
  String type;
  String friendlyName;

  //device settings
  String assignedName;
  String imageUrl;

  //NOTE: we only add a new rssi update IF we get new rssi from the scanner
  Queue<RssiUpdate> rssiUpdates;
  int maxRssiUpdates;

  DeviceData(
    this.id,
    this.type,
    this.friendlyName,
    this.assignedName,
    this.imageUrl,
    this.rssiUpdates,
    {
      this.maxRssiUpdates,
    }
  ){
    //maxRssiUpdates is not passed when you add the device
    if(maxRssiUpdates == null){
      maxRssiUpdates = 100; //MANUAL DEFAULT
    }
  }

  Map toJson(){ 
    Map map = new Map();
    map["id"] = json.encode(id);
    map["type"] = json.encode(type);
    map["friendlyName"] = json.encode(friendlyName);
    map["assignedName"] = json.encode(assignedName);
    map["imageUrl"] = json.encode(imageUrl);
    map["rssiUpdates"] = json.encode(rssiUpdates);
    map["maxRssiUpdates"] = json.encode(maxRssiUpdates);
    return map;
  }

  //-------------------------Static Functions
  
  static DeviceData toStruct(String string){
    //TODO... fill this in
  }

  //NOTE: has no default(would be added manually)
}

class RssiUpdate{
  int value;
  int dateTime; //from epoch

  RssiUpdate(
    this.value,
    this.dateTime,
  );

  Map toJson(){ 
    Map map = new Map();
    map["value"] = json.encode(value);
    map["dateTime"] = json.encode(dateTime);
    return map;
  }

  //-------------------------Static Functions

  static RssiUpdate toStruct(String string){

  }

  //NOTE: has no default(would be added manually)
}

//-------------------------LOCATION DATA-------------------------

//---
//1. we are using a Queues so that we can keep a max of X items efficiently
//2. this is because we dont really need constant time access
//3. we need to be able to add to the back
//4. we need to be able to remove from the front
//5. the keys Queue in both can return an index 
//    -that can then be used to find the item in another queue
//---

//NOTE: because Device Storage uses LocationStorage keys to keep track of their location history
//we DO NOT remove any location marked as being used by Devices
class LocationsData{
  //NOTE: we only add a new GPS update IF we get new GPS from the scanner
  //list of last couple gps updates (equivalent length)
  Queue<LocationStorage> locations;
  Queue<double> longitude;
  Queue<int> dateTimeUpdates;
  Queue<int> keys; //unique keys to things can address this location
  final int maxLocationUpdatesStored = 125;

  Map toJson(){ 
    Map map = new Map();
    return map;
  }

  //-------------------------Static Functions
  
  static LocationsData toStruct(String fileString){
    //TODO... fill this in
  }

  static LocationsData get defaultData{

  }
}

class LocationStorage{
  double latitude;
  double longitude;
  int dateTimeUpdates; //microseconds from epoch

  LocationStorage(
    this.latitude,
    this.longitude,
    this.dateTimeUpdates,
  );

  Map toJson(){ 
    Map map = new Map();
    return map;
  }

  //-------------------------Static Functions
  
  static LocationStorage toStruct(String fileString){
    //TODO... fill this in
  }

  //NOTE: has no default(would be added manually)
}