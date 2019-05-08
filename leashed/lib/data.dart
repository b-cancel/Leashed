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
  //NOTE: obviously there is no limit to this list
  List<DeviceData> deviceData;
  //NOTE: there is a limit to this list
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
  Queue<RssiUpdate> _rssiUpdates;

  //the location key is how many microsecondsBeforeEpoch for the GPS update
  //the rssi key is how many microsecondsBeforeEpoch for the BT update
  //NOTE: these are stored as strings from the sake of json.encode() working
  //but ultimate we are storing ints here
  Map<String, String> locationKeyToRssiKey;

  //NOTE: for now this is just used to eliminate the older update
  //when the maxRssiUpdates limit is passed
  int maxUpdates;
  //TODO: add a durationBeforeDeletionAllowed variable
  //  -when we reach maxRssiUpdates we don't just remove the older update
  //  -REMOVE the older update IF
  //    -the difference between the newest and the oldest update
  //    -is larger than durationBeforeDeletionAllowed
  //  -REMOVE other update ELSE
  //    -we remove an update that isnt as significant to tracking your location
  //    -ideally we want to get rid of updates that are more closer together
  //The IDEA behind this is, that we always know the general path of travel of our device
  //For Example: knowing that I was in 10 different locations in starbucks isnt all that helpful
  //So when I start getting rid of update data I should eliminate 9 of those 10 locations
  //Before removing all the other single points that I received from all different locations

  DeviceData(
    this.id,
    this.type,
    this.friendlyName,
    //always passable since friendly name will be copied to its value
    this.assignedName,
    //always passable since default image will be copied to its value
    this.imageUrl,
    //always passable since a set of rssiUpdates have to have occured
    //in order for you to detect the device in the first place
    this._rssiUpdates,
    {
      //will ONLY have these if its not the first time this thing is added
      this.locationKeyToRssiKey,
      this.maxUpdates,
    }
  ){
    if(locationKeyToRssiKey == null){
      locationKeyToRssiKey = new Map<String,String>();
    }
    if(maxUpdates == null){
      maxUpdates = 100; //MANUAL DEFAULT
    }
  }

  Map toJson(){ 
    Map map = new Map();
    map["id"] = json.encode(id);
    map["type"] = json.encode(type);
    map["friendlyName"] = json.encode(friendlyName);
    map["assignedName"] = json.encode(assignedName);
    map["imageUrl"] = json.encode(imageUrl);
    map["rssiUpdates"] = json.encode(_rssiUpdates);
    map["locationKeyToRssiKey"] = json.encode(locationKeyToRssiKey);
    map["maxUpdates"] = json.encode(maxUpdates);
    return map;
  }

  //-------------------------Mess With The Queue

  //NOTE: ONLY pass the optional param IF the GPS is known to be on
  addUpdate(
    RssiUpdate update, 
    bool gpsOn,
    //this will be the last gps update (only relevant within X Ammount of time)
    {int microsecondsSinceEpochForThisGpsUpdate}
    ){
    //-----add to back of line (newer points)
    _rssiUpdates.addLast(update); 

    //-----device whether or not whether to also track a gps update
    if(gpsOn && microsecondsSinceEpochForThisGpsUpdate != null){
      //NOTE: we already have this location saved but we need to link it up to this update

      //decide whether or not this location hasnt already been FIRST recorded by another rssi update
      if(locationKeyToRssiKey.containsKey(microsecondsSinceEpochForThisGpsUpdate) == false){
        String locationKey = microsecondsSinceEpochForThisGpsUpdate.toString();
        String rssiKey = update.microsecondsSinceEpoch.toString();
        locationKeyToRssiKey[locationKey] = rssiKey;
      }
      //ELSE... another update has already recorded this location
    }
    //ELSE... we updated our RSSI but 
    //1. our gps is off OR 
    //2. the last locaction was too far away to be relevnt

    //-----remove data if needed
    if(_rssiUpdates.length > maxUpdates){
      //remove from front of line (older points)
      _rssiUpdates.removeFirst();

      //----------------------------------------------------------------------------------------------------
      //TODO... reduce reference count by 1 for this particular GPS upate
      //----------------------------------------------------------------------------------------------------
    }
  }

  List<RssiUpdate> getUpdates(){
    return _rssiUpdates.toList();
  }

  //-------------------------Static Functions
  
  static DeviceData toStruct(String string){
    //TODO... fill this in
  }

  //NOTE: has no default(would be added manually)
}

class RssiUpdate{
  int value;
  int microsecondsSinceEpoch;

  RssiUpdate(
    this.value,
    this.microsecondsSinceEpoch,
  );

  Map toJson(){ 
    Map map = new Map();
    map["value"] = json.encode(value);
    map["microsecondsFromEpoch"] = json.encode(microsecondsSinceEpoch);
    return map;
  }

  //-------------------------Static Functions

  static RssiUpdate toStruct(String string){

  }

  //NOTE: has no default(would be added manually)
}

//-------------------------LOCATION DATA-------------------------

//NOTE: because Device Storage uses LocationStorage keys to keep track of their location history
//we DO NOT remove any location marked as being used by Devices
class LocationsData{
  //NOTE: we only add a new GPS update IF we get new GPS from the scanner
  //list of last couple gps updates (equivalent length)
  Queue<LocationStorage> _locations;
  int maxUpdates;

  LocationsData(
    this._locations,
    this.maxUpdates
  );

  //TODO: add a durationBeforeDeletionAllowed variable
  //Explained in [DeviceData]

  Map toJson(){ 
    Map map = new Map();
    map["locations"] = json.encode(_locations);
    map["maxUpdates"] = json.encode(maxUpdates);
    return map;
  }
  
  //-------------------------Mess With The Queue

  //NOTE: ONLY pass the optional param IF the GPS is known to be on
  addUpdate(LocationStorage update){
    //-----add to back of line (newer points)
    _locations.addLast(update); 

    //-----remove data if needed
    if(_locations.length > maxUpdates){
      //remove from front of line (older points)
      //TODO... only REMOVE IF the location isnt being used or reference by NO devices
      _locations.removeFirst();
    }
  }

  List<LocationStorage> getUpdates(){
    return _locations.toList();
  }

  //-------------------------Static Functions
  
  static LocationsData toStruct(String fileString){
    //TODO... fill this in
  }

  static LocationsData get defaultData{
    return LocationsData(
      new Queue<LocationStorage>(),
      100, //MANUAL DEFAULT
    );
  }
}

class LocationStorage{
  double latitude;
  double longitude;
  int microsecondsSinceEpoch;
  int referenceCount;

  LocationStorage(
    this.latitude,
    this.longitude,
    this.microsecondsSinceEpoch,
    {
      this.referenceCount,
    }
  ){
    if(referenceCount == null){
      referenceCount = 0;
    }
  }

  Map toJson(){ 
    Map map = new Map();
    map["latitude"] = json.encode(latitude);
    map["longitude"] = json.encode(longitude);
    map["microsecondsSinceEpoch"] = json.encode(microsecondsSinceEpoch);
    map["referenceCount"] = json.encode(referenceCount);
    return map;
  }

  //-------------------------Static Functions
  
  static LocationStorage toStruct(String string){
    //TODO... fill this in
  }

  //NOTE: has no default(would be added manually)
}