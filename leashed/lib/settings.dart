import 'package:flutter/material.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/picker/durationDisplay.dart';
import 'package:leashed/picker/durationPicker.dart';

class Settings extends StatefulWidget { 
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  DurationPicker picker;
  
  Duration getTimeBetweenUpdates(){
    return new Duration(minutes: 23, seconds: 34);
  }

  int getSearchAttemptsBefore(){
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Navigation.appGrey,
        title: new Text("Settings"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: new Text(
              "Time Between Background Updates",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          InkWell(
            onTap: (){
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  picker = new DurationPicker(
                    initialDuration: getTimeBetweenUpdates(),
                    onConfirm: () {
                      print("new picker" + picker.getDuration().toString());
                      Navigator.pop(context);
                    },
                    onCancel: () => Navigator.pop(context),
                  );
                  return picker;
                },
              );
            },
            child: DurationDisplay(
              value: () => getTimeBetweenUpdates(),
              showDays: false,
              showMilliseconds: false,
              showMicroseconds: false,
            ),
          ),
          /*
          Container(
            child: new Text("Search Attempts"),
          ),
          DurationDisplay(
            value: () => getSearchAttemptsBefore(),
          ),
          */
        ],
      )
    );
  }
}