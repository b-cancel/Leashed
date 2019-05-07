import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';

//NOTE: we will only enter this IF our bluetooth is already on
class Instruction extends StatefulWidget {
  final String imageUrl;
  final List<String> lines;
  final Function onDone;

  Instruction({
    @required this.imageUrl,
    @required this.lines,
    @required this.onDone,
  });

  @override
  _InstructionState createState() => _InstructionState();
}

class _InstructionState extends State<Instruction> {
  
  @override
  void initState() {
    super.initState();

    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    //listen to the bluetooth states changes
    ScannerStaticVars.bluetoothOn.addListener(customSetState);
  }

  @override
  void dispose(){
    ScannerStaticVars.bluetoothOn.removeListener(customSetState);
    super.dispose();
  }

  customSetState(){
    if(ScannerStaticVars.bluetoothOn.value == false){
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    //get size
    double imageSize = MediaQuery.of(context).size.width;
    double titleHeight = (MediaQuery.of(context).size.height - imageSize) / 2;

    //create list of text widgets
    List<Widget> textLines = new List<Widget>();
    for(int i = 0; i < widget.lines.length; i++){
      textLines.add(new Text(widget.lines[i]));
    }

    //return widget
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: new Text("Pattern Recognition"),
        ),
        body: new Column(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: titleHeight,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Navigation.blueGrey,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: textLines,
                ),
              ),
            ),
            Container(
              height: imageSize,
              width: imageSize,
              child: Image.asset(widget.imageUrl),
            ),
            Expanded(
              child: Center(
                child: new RaisedButton(
                  color: Navigation.blueGrey,
                  onPressed: () => widget.onDone(),
                  child: new Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}