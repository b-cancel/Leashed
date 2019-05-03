import 'package:flutter/material.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/picker/duration.dart';
import 'package:numberpicker/numberpicker.dart';

class LeashTightness extends StatelessWidget {
  //durations max time
  final ValueNotifier<Duration> redMaxTime = ValueNotifier<Duration>(Duration(seconds: 5));
  final ValueNotifier<Duration> yellowMaxTime = ValueNotifier<Duration>(Duration(seconds: 30));
  final ValueNotifier<Duration> greenMaxTime = ValueNotifier<Duration>(Duration(seconds: 60));

  //durations timeBetween
  final ValueNotifier<Duration> redTimeBetween = ValueNotifier<Duration>(Duration(seconds: 15));
  final ValueNotifier<Duration> yellowTimeBetween = ValueNotifier<Duration>(Duration(minutes: 7, seconds: 30));
  final ValueNotifier<Duration> greenTimeBetween = ValueNotifier<Duration>(Duration(minutes: 15));

  //table columns width
  final Map<int, TableColumnWidth> colWidths = {
    0: IntrinsicColumnWidth(),
    1: IntrinsicColumnWidth(),
    2: FlexColumnWidth(1.0),
  };

  //build method
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 0, bottom: 16),
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
            redMaxTime,
            redTimeBetween,
          ),
          buildTableRow(
            Container(
              color: Colors.yellow,
              child: new ColorCellText(
                text: "SECURE",
                flip: true,
              ),
            ),
            yellowMaxTime,
            yellowTimeBetween,
          ),
          buildTableRow(
            Container(
              color: Colors.green,
              child: new ColorCellText(
                text: "LOOSE",
              ),
            ),
            greenMaxTime,
            greenTimeBetween,
          ),
        ]
      ),
    );
  }

  TableRow buildTableRow(Widget color, ValueNotifier<Duration> maxTime, ValueNotifier<Duration> timeBetween){
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

//-------------------------Duration Pickers-------------------------

class ButtonCell extends StatefulWidget {
  const ButtonCell({
    Key key,
    @required this.time,
  }) : super(key: key);

  final ValueNotifier<Duration> time;

  @override
  _ButtonCellState createState() => _ButtonCellState();
}

class _ButtonCellState extends State<ButtonCell> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDialog(),
      child: Container(
        padding: EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(durationShortMinutesSeconds(widget.time.value)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    List<int> timeParts = getFormattedDuration(widget.time.value);
    int minutes = timeParts[2];
    int seconds = timeParts[3];

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(16),
                color: Navigation.blueGrey,
                child: Text(
                  'Title',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              DefaultTextStyle(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text("Minutes"),
                      Text("Seconds"),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  NumberPicker.integer(
                    initialValue: minutes,
                    minValue: 0,
                    maxValue: 60,
                    onChanged: (newValue){
                      minutes = newValue;
                    },
                  ),
                  NumberPicker.integer(
                    initialValue: seconds,
                    minValue: 0,
                    maxValue: 60,
                    onChanged: (newValue){
                      seconds = newValue;
                    },
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Confirm'),
                      onPressed: () {
                        //update value notifier so UI can update
                        widget.time.value = Duration(minutes: minutes, seconds: seconds);
                        //update UI
                        setState(() {});
                        //pop the picker
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}