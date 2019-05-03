import 'package:flutter/material.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/picker/durationPicker.dart';
import 'package:leashed/settingsHelper/leashTightness.dart';

class Settings extends StatefulWidget { 
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Color lightGrey = Color.fromRGBO(197, 201, 205, .75);
  final Color darkGrey = Colors.grey[900];
  //LIGHT: Color.fromRGBO(237, 240, 242, 1);
  //DARK: Color.fromRGBO(197, 201, 205, 1);
  DurationPicker picker;

  //message
  final TextEditingController messageField = new TextEditingController();
  final ValueNotifier<bool> editingField = new ValueNotifier<bool>(false);
  
  Duration getTimeBetweenUpdates(){
    return new Duration(minutes: 23, seconds: 34);
  }

  int getSearchAttemptsBefore(){
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    String text = "MODE";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Navigation.blueGrey,
        title: new Text("Settings"),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              new SectionLabel(
                lightGrey: lightGrey, 
                darkGrey: darkGrey,
                sectionName: "LEASH TIGHTNESS",
              ),
              new LeashTightness(),
              new SectionLabel(
                lightGrey: lightGrey, 
                darkGrey: darkGrey,
                sectionName: "EMERGENCY MESSAGE",
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16,8,16,8),
                child: new TextField(
                  controller: messageField,
                  onTap: (){
                    editingField.value = true;
                    setState(() {}); //show done button
                  },
                  decoration: InputDecoration(
                    hintText: "Type Your S.O.S Message Here",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  scrollPadding: EdgeInsets.only(bottom: 64), //For The Done Button
                ),
              ),
              new SectionLabel(
                lightGrey: lightGrey, 
                darkGrey: darkGrey,
                sectionName: "EMERGENCY CONTACTS",
              ),
            ],
          ),
          (editingField.value)
          ? Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              child: RaisedButton(
                color: Navigation.blueGrey,
                onPressed: (){
                  editingField.value = false;
                  //remove focus
                  FocusScope.of(context).requestFocus(new FocusNode());
                  //hide done button
                  setState(() {}); 
                },
                child: new Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          : Container(),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    Key key,
    @required this.lightGrey,
    @required this.darkGrey,
    @required this.sectionName,
  }) : super(key: key);

  final Color lightGrey;
  final Color darkGrey;
  final String sectionName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(20,20,8,8),
          decoration: BoxDecoration(
            color: lightGrey,
            border: Border(
              bottom: BorderSide(
                color: darkGrey,
                width: 2,
              ),
            ),
          ),
          child: new Text(
            sectionName,
            style: TextStyle(
              color: darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}