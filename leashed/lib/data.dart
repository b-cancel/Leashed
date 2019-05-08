import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:leashed/helper/structs.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class DataManager {
  static String fileName = "data.txt";
  static ValueNotifier<String> filePath = ValueNotifier<String>(""); 

  static init() async{
    String ourFilePath = await _localFilePath;
    if(fileExists(ourFilePath)){
      print("EXIST");
    }
    else print("NO EXISTS");
  }

  static bool fileExists(String path){
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> get _localFilePath async{
    final localPath = await _localPath;
    return '$localPath/$fileName';
  }

  static Future<File> get _localFile async {
    final path = await _localFilePath;
    return File(path);
  }

  /*
  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }
  */
}