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
  int microsecondsUntilLastGpsUpdateisUseless;
  //NOTE: obviously there is no limit to this list
  List<DeviceData> deviceData;
  int defaultDeviceDataMaxUpdates;
  //NOTE: there is a limit to this list
  LocationsData locationData;

  AppData(
    this.settingsData,
    this.sosData,
    this.microsecondsUntilLastGpsUpdateisUseless,
    this.deviceData,
    this.defaultDeviceDataMaxUpdates,
    this.locationData,
  );

  Map toJson(){ 
    Map map = new Map();
    map["settingsData"] = json.encode(settingsData);
    map["sosData"] = json.encode(sosData);
    map["microsecondsUntilLastGpsUpdateisUseless"] = json.encode(microsecondsUntilLastGpsUpdateisUseless);
    map["deviceData"] = json.encode(deviceData);
    map["defaultDeviceDataMaxUpdates"] = json.encode(defaultDeviceDataMaxUpdates);
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
      Duration(seconds: 1).inMicroseconds, //MANUAL DEFAULT
      new List<DeviceData>(),
      100,  //MANUAL DEFAULT
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

  //MANUAL DEFAULT
  static ColorSetting get defaultRedData{
    return ColorSetting(
      Duration(seconds: 5).inMicroseconds,
      Duration(seconds: 15).inMicroseconds,
    );
  }

  //MANUAL DEFAULT
  static ColorSetting get defaultYellowData{
    return ColorSetting(
      Duration(seconds: 30).inMicroseconds,
      Duration(minutes: 7, seconds: 30).inMicroseconds,
    );
  }

  //MANUAL DEFAULT
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
  Queue<RssiUpdate> rssiUpdates; //DONT ADD MANUALLY (use addUpdate)

  //the location key is how many microsecondsBeforeEpoch for the GPS update
  //the rssi key is how many microsecondsBeforeEpoch for the BT update
  //NOTE: these are stored as strings from the sake of json.encode() working
  //  - it only know how to automatically toJson maps with String keys
  //but ultimate we are storing ints here
  Map<String, String> locationKeyToRssiKey;
  //TODO... what we really need is a two way map...
  //I should be able to 
  //1. grab my value from my key in constant time
  //2. AND graby my key from my value in constant time
  //We Need this because when we reach our maxUpdates limit
  //  - everytime we add to the list we also remove from it
  //  - adding is constantly time
  //  - BUT removing requires that we find the key of a certain value
  //    - which takes O(n)
  //Alternate Solution
  //  - If the map stay in order
  //  - and sets also stay in order
  //  - we might be able to keep a set of value
  //  - then simply grab the index of the value in the set
  //  - that index will be the index of the key
  //  - that we need to remove from the key to value mapping
  //this works in this scenario because 
  //1. every key is unique
  //  - since we only record the location the first time its detected
  //2. every value is unique
  //  - since we know multiple scans of the same device can't be read in at once
  //TODO... check if a two way map is worth it over just our current method

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
    this.rssiUpdates,
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
      maxUpdates = DataManager.appData.defaultDeviceDataMaxUpdates;
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
    map["locationKeyToRssiKey"] = json.encode(locationKeyToRssiKey);
    map["maxUpdates"] = json.encode(maxUpdates);
    return map;
  }

  //-------------------------Mess With The Queue

  addUpdate(RssiUpdate update){
    //-----add to back of line (newer points)
    rssiUpdates.addLast(update); 

    //-----add gps update to rssi update
    int rssiDateTime = update.microsecondsSinceEpoch;
    int lastGpsDateTime = DataManager.appData.locationData.locations.last.microsecondsSinceEpoch;
    //NOTE: we KNOW that rssiDateTime > gpsDateTime
    int microsecondsSinceLastGpsUpdate = rssiDateTime - lastGpsDateTime;

    if(microsecondsSinceLastGpsUpdate < DataManager.appData.microsecondsUntilLastGpsUpdateisUseless){
      //NOTE: every NEW gps location can only map to ONE rssiUpdate (the first it matches with)

      //decide whether or not this location hasnt already been FIRST recorded by another rssi update
      if(locationKeyToRssiKey.containsKey(lastGpsDateTime) == false){
        //save the location key
        String locationKeyString = lastGpsDateTime.toString();
        String rssiKeyString = rssiDateTime.toString();
        locationKeyToRssiKey[locationKeyString] = rssiKeyString;

        //tell the location we are using it
        DataManager.appData.locationData.increaseReferenceCount(lastGpsDateTime);
      }
      //ELSE... another update has already recorded this location
    }
    //ELSE... the update happened too long ago
    //1. the GPS is OFF
    //2. the GPS simply isn't working properly

    //-----remove data if needed
    if(rssiUpdates.length > maxUpdates){
      //---tell the location we are no longer using it

      //get the key of the rssi update we are removing
      int valueOr_RssiKey = rssiUpdates.first.microsecondsSinceEpoch;

      //get the location it maps to
      String locationKeyString = locationKeyToRssiKey.keys.firstWhere(
        (key) => (int.parse(locationKeyToRssiKey[key]) == valueOr_RssiKey), 
        orElse: () => null,
      );

      //this rssi udpate has a gps update reference
      if(locationKeyString != null){
        //reduce its reference count
        int locationKey = int.parse(locationKeyString);
        DataManager.appData.locationData.decreaseReferenceCount(locationKey);
      }
      
      //---remove from front of line (older points)
      rssiUpdates.removeFirst();
    }
  }

  List<RssiUpdate> getUpdates(){
    return rssiUpdates.toList();
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
  Queue<LocationStorage> locations; //DONT ADD MANUALLY (use addUpdate)
  //int locationsReferenced;
  int maxUpdates;

  LocationsData(
    //TODO... fix some stuff here...
    this.locations,
    //this.locationsReferenced,
    this.maxUpdates
  );

  //TODO: add a durationBeforeDeletionAllowed variable
  //Explained in [DeviceData]

  Map toJson(){ 
    Map map = new Map();
    map["locations"] = json.encode(locations);
    //TODO... fix some stuff here...
    map["maxUpdates"] = json.encode(maxUpdates);
    return map;
  }
  
  //-------------------------Mess With The Queue

  //NOTE: ONLY pass the optional param IF the GPS is known to be on
  addUpdate(LocationStorage update){
    //-----add to back of line (newer points)
    locations.addLast(update); 

    //-----remove data if needed
    if(locations.length > maxUpdates){
      //remove from front of line (older points)
      //TODO... only REMOVE IF the location isnt being used or reference by NO devices
      locations.removeFirst();
    }
  }

  List<LocationStorage> getUpdates(){
    return locations.toList();
  }

  increaseReferenceCount(int microsecondsSinceEpochKEY){
    //TODO... increase the reference count
    //TODO... IF its the first time we are referencing this increase the counter
  }

  decreaseReferenceCount(int microsecondsSinceEpochKEY){
    //TODO... decrease reference count
    //TODO... IF its NOW not reference then decrease the counter
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
    //TODO... missing something here
    map["referenceCount"] = json.encode(referenceCount);
    return map;
  }

  //-------------------------Static Functions
  
  static LocationStorage toStruct(String string){
    //TODO... fill this in
  }

  //NOTE: has no default(would be added manually)
}