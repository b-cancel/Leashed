import 'package:flutter/material.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/picker/durationDisplay.dart';
import 'package:leashed/picker/durationPicker.dart';
import 'package:numberpicker/numberpicker.dart';


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
  
  Duration getTimeBetweenUpdates(){
    return new Duration(minutes: 23, seconds: 34);
  }

  int getSearchAttemptsBefore(){
    return 3;
  }

  final Map<int, TableColumnWidth> colWidths = {
    0: IntrinsicColumnWidth(),
    1: IntrinsicColumnWidth(),
    2: FlexColumnWidth(1.0),
  };

  @override
  Widget build(BuildContext context) {
    String text = "MODE";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Navigation.blueGrey,
        title: new Text("Settings"),
      ),
      body: Column(
        children: <Widget>[
          new SectionLabel(
            lightGrey: lightGrey, 
            darkGrey: darkGrey,
            sectionName: "LEASH TIGHTNESS",
          ),
          Container(
            padding: EdgeInsets.only(top: 8, bottom: 16),
            child: Table(
              columnWidths: colWidths,
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: new TableHeader(
                        title: "MODE",
                        description: "Constantly Using Bluetooth"
                        + "\n" + "Is A Battery Life Killer"
                        + "\n"
                        + "\n" + "But It Might Be Necessary"
                        + "\n" + "If You Are Afraid Of Theft"
                        + "\n" 
                        + "\n" + "Leashed Let's You Choose"
                        + "\n"
                        + "\n" + "When You Want To"
                        + "\n" + "Use Your Battery Life"
                        + "\n" + "For That Extra Bit Of Security",
                      ),
                    ),
                    TableCell(
                      child: new TableHeader(
                        title: "CHECK DURATION",
                        description: "Sometimes A Device"
                        + "\n" + "May Be In Range"
                        + "\n"
                        + "\n" + "But There Is So Much Interferance"
                        + "\n" + "It Has Trouble Reporting Back"
                        + "\n" 
                        + "\n" + "Leashed Let's You Choose"
                        + "\n" + "For Each Mode"
                        + "\n"
                        + "\n" + "How Long Your Phone"
                        + "\n" + "Waits For A Device"
                        + "\n" + "Until It's Considered Disconnected"
                        + "\n" + "And You Are Alerted",
                      ),
                    ),
                    TableCell(
                      child: new TableHeader(
                        title: "INTERVAL BETWEEN",
                        description: "Because Using Bluetooth"
                        + "\n" + "Is A Battery Life Killer"
                        + "\n"
                        + "\n" + "We Only Want To Have It On"
                        + "\n" + "When Absolutely Necessary"
                        + "\n" 
                        + "\n" + "Leashed Let's You Choose"
                        + "\n" + "For Each Mode"
                        + "\n"
                        + "\n" + "How Long Your Phone Waits"
                        + "\n" + "Between Device Check-Ins",
                      ),
                    ),
                  ]
                ),
                buildTableRow(
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.black, Colors.red], // whitish to gray
                        tileMode: TileMode.repeated, // repeats the gradient over the canvas
                      ),
                    ),
                    child: new ColorCellText(
                      text: "TIGHT",
                    ),
                  ),
                  Duration(seconds: 5),
                  Duration(seconds: 15),
                ),
                buildTableRow(
                  Container(
                    color: Colors.yellow,
                    child: new ColorCellText(
                      text: "SECURE",
                      flip: true,
                    ),
                  ),
                  Duration(seconds: 30),
                  Duration(minutes: 7, seconds: 30),
                ),
                buildTableRow(
                  Container(
                    color: Colors.green,
                    child: new ColorCellText(
                      text: "LOOSE",
                    ),
                  ),
                  Duration(minutes: 1),
                  Duration(minutes: 15),
                ),
              ]
            ),
          ),
          new SectionLabel(
            lightGrey: lightGrey, 
            darkGrey: darkGrey,
            sectionName: "EMERGENCY CONTACTS",
          ),
        ],
      )
      
      
      /*Column(
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
        ],
      )*/
    );
  }

  TableRow buildTableRow(Widget color, Duration maxTime, Duration timeBetween){
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: color,
        ),
        TableCell(
          child: new ButtonCell(time: maxTime),
        ),
        TableCell(
          child: new ButtonCell(time: timeBetween),
        ),
      ]
    );
  }
}

class TableHeader extends StatefulWidget {
  const TableHeader({
    Key key,
    @required this.title,
    @required this.description,
  }) : super(key: key);

  final String title;
  final String description;

  @override
  _TableHeaderState createState() => _TableHeaderState();
}

class _TableHeaderState extends State<TableHeader> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => moreInfo(),
      child: Container(
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: new Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  moreInfo(){
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                color: Navigation.blueGrey,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(widget.description),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.all(8),
                      child: FlatButton(
                        child: Text('Neat!'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class ButtonCell extends StatefulWidget {
  const ButtonCell({
    Key key,
    @required this.time,
  }) : super(key: key);

  final Duration time;

  @override
  _ButtonCellState createState() => _ButtonCellState();
}

class _ButtonCellState extends State<ButtonCell> {
  double _currentPrice = 2;

   void _showDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.decimal(
          minValue: 1,
          maxValue: 10,
          title: new Text("Pick a new price"),
          initialDoubleValue: _currentPrice,
        );
      }
    ).then((int value) {
      if (value != null) {
        setState(() => _currentPrice = value.toDouble());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        _showDialog();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(durationShortMinutesSeconds(widget.time)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class ColorCellText extends StatelessWidget {
  final String text;
  final bool flip;

  const ColorCellText({
    this.text,
    this.flip: false,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16,8,8,8),
      child: Text(
        text,
        style: TextStyle(
          color: (flip) ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
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