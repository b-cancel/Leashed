import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

//NOTES
//[A] search "MANUAL DEFAULT" To Find The Defaults I Selected
//[B] int, double, and bool -> should not be encoded
//[C] whats used depends heavily on the situation (dep, types, array, map, etc)
//1. sometimes you use json.encode()
//  - so far json.encode() needs to be used for arrays and maps
//2. other times you use myToJson()
//[D] for some reason 
//1. sometimes map keys need to have quotes 
//2. and other times they dont

class DataManager {
  static String _fileName = "leashedAppData.txt";
  static String _filePath;
  static File _fileReference;
  static String _fileString;
  static AppData appData; //accessible by all other functions

  static testConversion() async{
    //get references to the file
    _filePath = await _localFilePath;
    
    //create or read the file
    _fileReference = File(_filePath);

    //delete the file
    if(_fileExists) _deleteFile;
    //create the file
    await _createFile;

    //fill our structs with defaults
    await _writeStructWithDefaults;

    //fill our struct with sosContacts
    appData.sosData.sosContacts.add(SosContact("jake","work","(956) 777-2692"));
    appData.sosData.sosContacts.add(SosContact("Jessica","cell","(956) 128-1297"));

    //fill our struct with location data
    /*
    appData.locationData.microsecondsSinceEpoch2Location = {
      "3" : LocationData(1112.312, 7.43, referenceCount: 3),
      "1" : LocationData(12.312, 788.7043, referenceCount: 7),
      "2" : LocationData(212.312, 788.843, referenceCount: 0),
      "4" : LocationData(12.553312, 97.43, referenceCount: 5),
      "5" : LocationData(7812.312, 79.43, referenceCount: 1),
    };
    */

    //fill our struct with device data
    appData.deviceData.add(
      DeviceData(
        "aca3c70rqm32c9d", 
        "Low Energy", 
        "Friendly", 
        "Assigned", 
        "image url", 
        {
          "1":1,
          "2":2,
          "3":5,
          "5":10,
          "6":11,
        },
        locationKeyToRssiKey: {
          "key1" : "value3",
          "key124" : "value7",
          "key50" : "value03",
        },
        maxUpdates: 100,
      ),
    );

    appData.deviceData.add(
      DeviceData(
        "125235123", 
        "Low", 
        "freln", 
        "ass", 
        "imagr", 
        {
          "1":1,
          "5":2,
          "6":3,
          "7":14,
          "9":15,
        },
        locationKeyToRssiKey: {
          "keyo" : "124",
          "kaya" : "valuq134e7",
          "kem" : "123",
        },
        maxUpdates: 100,
      ),
    );

    /*
    map[addQuotes("locationKeyToRssiKey")] = json.encode(locationKeyToRssiKey);
    */

    //save the defaults on in the file
    await _writeStructToFile;

    //print our file
    _printFile;
  }

  static init() async{
    testConversion();

    /*
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
    */
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
    _fileString = myToJson(appData);
    //write file
    await _fileReference.writeAsString(_fileString);
  }

  static get _writeFileToStruct async{
    //read file
    _fileString = await _fileReference.readAsString();
    //convert String to Struct
    appData = AppData.toStruct(_fileString);
  }

  static get _printFile async{
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String fileString = await _fileReference.readAsString();
    Map jsonMap = jsonDecode(fileString);
    //NOTE: encoder.convert(jsonMap) here should work
    //BUT because of some caching issue with the function it cuts off
    //making it never cut off is going to be difficult
    //but I could split the map into 6 parts and print that
    var keys = jsonMap.keys.toList();
    print("{");
    print("-------------------------");
    for(int i = 0; i < keys.length; i++){
      var key = keys[i];
      print(addQuotes(key) + ": " + encoder.convert(jsonMap[key]));
      print("-------------------------");
    }
    print("}");
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
    map[addQuotes("settingsData")] = myToJson(settingsData);
    map[addQuotes("sosData")] = myToJson(sosData);
    map[addQuotes("microsecondsUntilLastGpsUpdateisUseless")] = microsecondsUntilLastGpsUpdateisUseless;
    map[addQuotes("deviceData")] = json.encode(deviceData);
    map[addQuotes("defaultDeviceDataMaxUpdates")] = defaultDeviceDataMaxUpdates;
    map[addQuotes("locationData")] = myToJson(locationData);

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
    map[addQuotes("redSetting")] = redSetting.toJson().toString();
    map[addQuotes("yellowSetting")] = yellowSetting.toJson().toString();
    map[addQuotes("greenSetting")] = greenSetting.toJson().toString();
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
    map[addQuotes("checkDuration")] = checkDuration;
    map[addQuotes("intervalDuration")] = intervalDuration;
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
    map[addQuotes("sosMessage")] = addQuotes(sosMessage); 
    map[addQuotes("sosContacts")] = json.encode(sosContacts);
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
  String name; //TODO... we assume this CANT BE EMPTY (otherwise things will break)
  String label;
  String number;

  SosContact(
    this.name,
    this.label,
    this.number,
  );

  Map toJson(){ 
    Map map = new Map();
    map["name"] = myToJson(name);
    map["label"] = myToJson(label);
    map["number"] = myToJson(number);
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
  //DONT ADD MANUALLY (use addUpdate)
  Map<String, int> microsecondsSinceEpoch2Value;
  Queue<String> rssiUpdatesOrder; 

  //the location key is how many microsecondsBeforeEpoch for the GPS update
  //the rssi key is how many microsecondsBeforeEpoch for the BT update
  //NOTE: the keys are stored as strings from the sake of json.encode() working
  //  - it only knows how to automatically toJson maps with String keys
  //but ultimately we are storing ints here
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
    this.microsecondsSinceEpoch2Value,
    {
      //will ONLY have these if its not the first time this thing is added
      this.locationKeyToRssiKey,
      this.maxUpdates,
    }
  ){
    rssiUpdatesOrder = mapToOrderedQueue(microsecondsSinceEpoch2Value);

    //NOTE: add defaults for the first time we create this
    if(locationKeyToRssiKey == null){
      locationKeyToRssiKey = new Map<String,String>();
    }
    if(maxUpdates == null){
      maxUpdates = DataManager.appData.defaultDeviceDataMaxUpdates;
    }
  }

  Map toJson(){ 
    Map map = new Map();
    map["id"] = addQuotes(id);
    map["type"] = addQuotes(type);
    map["friendlyName"] = addQuotes(friendlyName);
    map["assignedName"] = addQuotes(assignedName);
    map["imageUrl"] = addQuotes(imageUrl);
    map["microsecondsSinceEpoch2Value"] = json.encode(microsecondsSinceEpoch2Value);
    //NOTE: we don't need to save rssiUpdatesOrder since its impliable from the above
    map["locationKeyToRssiKey"] = json.encode(locationKeyToRssiKey);
    map["maxUpdates"] = maxUpdates;
    return map;
  }

  //-------------------------Mess With The Queue

  addUpdate(int value, int microsecondsSinceEpoch){
    //-----add to back of line (newer points)
    microsecondsSinceEpoch2Value[microsecondsSinceEpoch.toString()] = value;
    rssiUpdatesOrder.addLast(microsecondsSinceEpoch.toString()); 

    //-----check if we can use the last gps update
    int rssiDateTime = microsecondsSinceEpoch;
    String lastGpsDateTime = DataManager.appData.locationData.microsecondsSinceEpoch2Location.keys.last;
    //NOTE: we KNOW that rssiDateTime > gpsDateTime
    int microsecondsSinceLastGpsUpdate = rssiDateTime - int.parse(lastGpsDateTime);

    //-----add gps update to rssi update
    if(microsecondsSinceLastGpsUpdate < DataManager.appData.microsecondsUntilLastGpsUpdateisUseless){
      //NOTE: every NEW gps location can only map to ONE rssiUpdate (the first it matches with)

      //decide whether or not this location hasnt already been FIRST recorded by another rssi update
      if(locationKeyToRssiKey.containsKey(lastGpsDateTime) == false){
        //save the location key
        String rssiKeyString = rssiDateTime.toString();
        locationKeyToRssiKey[lastGpsDateTime] = rssiKeyString;

        //tell the location we are using it
        DataManager.appData.locationData.increaseReferenceCount(lastGpsDateTime);
      }
      //ELSE... another update has already recorded this location
    }
    //ELSE... the update happened too long ago
    //1. the GPS is OFF
    //2. the GPS simply isn't working properly

    //-----remove data if needed
    if(rssiUpdatesOrder.length > maxUpdates){
      //---get the oldest key to remove
      String microsecondsSinceEpochRssiKey = rssiUpdatesOrder.first;

      //---tell the location we are no longer using it
      //get the location it maps to
      String microsecondsSinceLastEpochLocationKey = locationKeyToRssiKey.keys.firstWhere(
        (key) => (locationKeyToRssiKey[key] == microsecondsSinceEpochRssiKey), 
        orElse: () => null,
      );

      //this rssi udpate has a gps update reference
      if(microsecondsSinceLastEpochLocationKey != null){ //reduce its reference count
        DataManager.appData.locationData.decreaseReferenceCount(microsecondsSinceLastEpochLocationKey);
      }
      
      //---remove from front of line (older points)
      rssiUpdatesOrder.removeFirst();
      microsecondsSinceEpoch2Value.remove(microsecondsSinceEpochRssiKey);
    }
  }

  //NOTE: this doesnt remove the device
  //our device is simply auto garbage collected when we remove it from our list
  //This function simply breaks the references this object holds to our locations
  clearLocationReferences(){
    List<String> locationsReferenced = locationKeyToRssiKey.keys.toList();
    for(int i = 0; i < locationsReferenced.length; i++){
      DataManager.appData.locationData.decreaseReferenceCount(locationsReferenced[i]);
    }
  }

  //-------------------------Static Functions
  
  static DeviceData toStruct(String string){
    //TODO... fill this in
  }

  //NOTE: has no default(would be added manually)
}

//-------------------------LOCATION DATA-------------------------

//NOTE: because Device Storage uses LocationStorage keys to keep track of their location history
//we DO NOT remove any location marked as being used by Devices
class LocationsData{
  //NOTE: we only add a new GPS update IF we get new GPS from the scanner
  //list of last couple gps updates (equivalent length)
  Map<String, LocationData> microsecondsSinceEpoch2Location;
  Queue<String> locationUpdatesOrder; //DONT ADD MANUALLY (use addUpdate)
  int locationsReferenced;
  int maxExtraUpdates;

  LocationsData(
    this.microsecondsSinceEpoch2Location,
    this.locationsReferenced,
    this.maxExtraUpdates
  ){
    locationUpdatesOrder = mapToOrderedQueue(microsecondsSinceEpoch2Location);
  }

  //TODO: add a durationBeforeDeletionAllowed variable
  //Explained in [DeviceData]

  Map toJson(){ 
    Map map = new Map();
    map[addQuotes("microsecondsSinceEpoch2Location")] = mapToJson(microsecondsSinceEpoch2Location);
    //NOTE: we don't need to save locationUpdatesOrder since its impliable from the above
    map[addQuotes("locationsReferenced")] = locationsReferenced;
    map[addQuotes("maxExtraUpdates")] = maxExtraUpdates;
    return map;
  }
  
  //-------------------------Mess With The Queue

  //NOTE: ONLY pass the optional param IF the GPS is known to be on
  addUpdate(double latitude, double longitude, int microsecondsSinceEpoch){
    //-----create struct
    LocationData update = LocationData(latitude, longitude);

    //-----add to back of line (newer points)
    locationUpdatesOrder.addLast(microsecondsSinceEpoch.toString()); 
    microsecondsSinceEpoch2Location[microsecondsSinceEpoch.toString()] = update;

    //-----remove data if needed
    if(locationUpdatesOrder.length > (locationsReferenced + maxExtraUpdates)){
      //remove from front of line (older points)
      //NOTE: we are removing the oldest point possible that ISN'T being used by a BLE Device

      //NOTE: this is guaranteed to be filled below
      String locationToRemoveIndex;

      //iterate through all locations to find the FIRST that isn't being referenced
      List<String> theLocations = locationUpdatesOrder.toList();
      int indexBeingChecked = 0;
      while(locationToRemoveIndex == null){
        String locationIndex = theLocations[indexBeingChecked];
        LocationData theLocation = microsecondsSinceEpoch2Location[locationIndex];
        if(theLocation.referenceCount > 0){
          //move on to checking if the next location is not used
          indexBeingChecked++;
        }
        else{
          locationToRemoveIndex = locationIndex;
          break;
        }
      }
      
      //remove the location that we no longer need
      locationUpdatesOrder.remove(locationToRemoveIndex);
      microsecondsSinceEpoch2Location.remove(locationToRemoveIndex);
    }
  }

  increaseReferenceCount(String microsecondsSinceEpochKEY){
    LocationData locationToUpdate = microsecondsSinceEpoch2Location[microsecondsSinceEpochKEY];
    locationToUpdate.referenceCount += 1;
    if(locationToUpdate.referenceCount == 1){ //first time we are referencing this location
      locationsReferenced++;
    }
  }

  decreaseReferenceCount(String microsecondsSinceEpochKEY){
    LocationData locationToUpdate = microsecondsSinceEpoch2Location[microsecondsSinceEpochKEY];
    locationToUpdate.referenceCount -= 1;
    if(locationToUpdate.referenceCount == 0){ //we are no longer referencing this location
      locationsReferenced--;
    }
  }

  //-------------------------Static Functions
  
  static LocationsData toStruct(String fileString){
    //TODO... fill this in
  }

  static LocationsData get defaultData{
    return LocationsData(
      new Map<String, LocationData>(),
      //initially you have no locations 
      //and therefore no references
      0, 
      100, //MANUAL DEFAULT
    );
  }
}

class LocationData{
  double latitude;
  double longitude;
  int referenceCount;

  LocationData(
    this.latitude,
    this.longitude,
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
    map[addQuotes("latitude")] = latitude;
    map[addQuotes("longitude")] = longitude;
    map[addQuotes("referenceCount")] = referenceCount;
    return map;
  }

  //-------------------------Static Functions
  
  static LocationData toStruct(String string){
    //TODO... fill this in
  }

  //NOTE: has no default(would be added manually)
}

//NOTE: orderedQueue can be easily implied by reading in map
Queue<String> mapToOrderedQueue(Map<String, dynamic> map){
  //create empty queue for filling
  Queue<String> orderedQueue = Queue<String>();
  //temporary rssiUpdate for easy sorting
  List<String> keyOrderedList = map.keys.toList();
  //smallest to largest (11, 21) 
  //11 since epoch happened further back than 21 since epoch
  keyOrderedList.sort(); 
  //add the smallest numbers to the back of the line first
  for(int i = 0; i < keyOrderedList.length; i++){
    orderedQueue.addLast(keyOrderedList[i]);
  }
  //return the queue
  return orderedQueue;
}

final String quote = "\"";
remQuotes(String str){
  if(str.length >= 2){
    String startChar = str[0];
    String endChar = str[str.length - 1];
    if(startChar == quote && endChar == quote){
      return str.substring(1, str.length-2);
    }
    else return str;
  }
  else return str;
}

String addQuotes(String str){
  return quote + str + quote;
}

String myToJson(dynamic data){
  //handle primatives
  if(data is String) return remQuotes(data);
  else{
    return remQuotes(data.toJson().toString());
  }
}

String mapToJson(Map<String,dynamic> map){
  String str = "{";
  List<String> keys = map.keys.toList();
  for(int i = 0; i < keys.length; i++){
    str += addQuotes(keys[i]);
    str += " : ";
    var location = map[keys[i]];
    if(location is LocationData){
      str += location.toJson().toString();
    }
    else str += addQuotes("value");
    if(i != (keys.length - 1)) str += ",";
  }
  str += "}";
  return str;
}