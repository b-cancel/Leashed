import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';

//This Widget
//IF the bluetooth if OFF -> asks user to turn it on
//IF the bluetooth is ON
//  1. automatically starts the scanner and then goes to the next page
//  2. exits the scanner if the user turns off the bluetooth
//    IF the user turns off bluetooth AFTER the scanner has started
//    which would indicate an ultimate troll
class ScanStarter extends StatefulWidget {
  final Widget child;

  const ScanStarter({
    this.child,
  });

  @override
  _ScanStarterState createState() => _ScanStarterState();
}

class _ScanStarterState extends State<ScanStarter>{
  final ValueNotifier<int> potentialMessageIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    //super init
    super.initState();

    //travels away from this widget when the user turns the bluetooth off
    //turns on the scanner when the user turns bluetooth on
    ScannerStaticVars.bluetoothOn.addListener(navigationAwayIfTurnedOff);

    //show the user what they need to do to get things working (turn on OR wait)
    ScannerStaticVars.bluetoothOn.addListener(customSetState); //show that you need to turn bluetooth on
    ScannerStaticVars.isScanning.addListener(customSetState); //show that the scanner is turning on

    //start the scan ONLY if the bluetooth is already on
    if(ScannerStaticVars.bluetoothOn.value){
      //start the scanner after the first build 
      //the user will instantly see the effect of them pressing the plus
      startScanner();
    }
  }

  @override
  void dispose(){
    //stop the scanner
    ScannerStaticVars.stopScan();

    //travels away from this widget when the user turns the bluetooth off
    //turns on the scanner when the user turns bluetooth on
    ScannerStaticVars.bluetoothOn.removeListener(navigationAwayIfTurnedOff);

    //show the user what they need to do to get things working (turn on OR wait)
    ScannerStaticVars.bluetoothOn.removeListener(customSetState); //show that you need to turn bluetooth on
    ScannerStaticVars.isScanning.removeListener(customSetState); //show that the scanner is turning on

    //super dispose
    super.dispose();
  }

  //-----Listeners START

  customSetState(){
    if(mounted){
      setState((){});
    }
  }

  navigationAwayIfTurnedOff() async{
    if(ScannerStaticVars.bluetoothOn.value == false){
      ScannerStaticVars.stopScan();
      Navigator.of(context).maybePop();
    }
    else{
      startScanner();
    }
  }

  startScanner(){
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ScannerStaticVars.startScan(),
    );
  }

  //-----Listeners END

  @override
  Widget build(BuildContext context) {
    if(ScannerStaticVars.bluetoothOn.value){
      if(ScannerStaticVars.isScanning.value){
        //---Sizing for our Scanner
        double height = MediaQuery.of(context).size.height / 5;
        height *= (5/4);

        //---Sizing For Our Arrow
        double arrowWidth = (MediaQuery.of(context).size.width / 3) / 2;

        //---Show Scanner
        return widget.child;
      }
      else{
        return new Builder(
          builder: (BuildContext context) {
            return InkWell(
              onTap: (){
                //Inform the user that it might fail
                final SnackBar msg = SnackBar(
                  content: Text(
                    'Trying To Re-Start The Scanner' 
                    + '\n' 
                    + 'If It Fails Please Try Again',
                  ),
                );
                Scaffold.of(context).showSnackBar(msg);
                //Attempt to Start Up The Scanner
                ScannerStaticVars.startScan();
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Please Wait',
                          style: TextStyle(
                            fontSize: 48,
                          ),
                        ),
                        Container(
                          height: 8,
                        ),
                        Image.asset(
                          "assets/pngs/hourglass.png",
                          width: 150,
                        ),
                        Container(
                          height: 8,
                        ),
                        Text(
                          "For The Bluetooth Scanner",
                        ),
                        Text(
                          "To Start Up",
                        ),
                      ],
                    ),
                  ),
                )
              ),
            );
          }
        );
      }
    }
    else{
      return BluetoothOff(
        bluetoothOffWidget: BluetoothOffWidget.page,
      );
    }
  }
}

class Hints extends StatelessWidget {
  final List<String> lines;

  const Hints({
    this.lines,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> lineWidgets = new List<Widget>();
    for(int i = 0; i < lines.length; i++){
      lineWidgets.add(Text(lines[i]));
    }

    return Column(
      children: lineWidgets,
    );
  }
}

class ArrowWidget extends StatelessWidget {
  const ArrowWidget({
    @required this.arrowWidth,
    @required this.outlineWidth,
    this.cleanOutline: false,
    @required this.outlineColor,
    @required this.arrowColor,
  });

  final double arrowWidth;
  final double outlineWidth;
  final bool cleanOutline;
  final Color outlineColor;
  final Color arrowColor;

  @override
  Widget build(BuildContext context) {
    double arrowHeight = 0;

    return Container(
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              height: arrowHeight,
              width: arrowWidth + outlineWidth,
              color: outlineColor,
              child: Text(""),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: (cleanOutline)
              ? outlineWidth / 2
              : 0,
            ),
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                height: arrowHeight - (
                  (cleanOutline) 
                  ? outlineWidth 
                  : 0
                ),
                width: arrowWidth,
                color: arrowColor,
                child: Text(""),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height/2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}

/*
Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Navigation.blueGrey,
                fontSize: 18,
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        color: Navigation.blueGrey,
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color: Colors.white
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text("Signal"),
                                Text("Strength"),
                                Text("Of"),
                                RichText(
                                  text: TextSpan(
                                    text: "91",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text("Out of 100"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    new ArrowWidget(
                      arrowWidth: arrowWidth, 
                      outlineWidth: 15,
                      outlineColor: Navigation.blueGrey,
                      arrowColor: Navigation.blueGrey,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Indicates"),
                              Text("You"),
                              Text("Are"),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "10",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Navigation.blueGrey,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "ft",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Navigation.blueGrey,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                              Text("Away"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.blue,
                height: height,
                child: Text("middle"),
              ),
            ),
            InkWell(
              onLongPress: (){
                //go to next potential message
                potentialMessageIndex.value += 1;

                //make sure we don't overflow
                if(potentialMessageIndex.value >= 4){ //TODO... set depending
                  potentialMessageIndex.value = 0;
                }
                
                //show UI difference
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: Navigation.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    //NOTE: I can't pass in the children otherwise DefaultTextStyle won't work
                    children: <Widget>[
                      Opacity(
                        opacity: (potentialMessageIndex.value == 0) ? 1 : 0,
                        child: new Hints(
                          lines: [
                            "Record The Device's Signature",
                            "And We Can Help You",
                            "Interpret The Device's Signal",
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: (potentialMessageIndex.value == 1) ? 1 : 0,
                        child: Hints(
                          lines: [
                            "You Are Between",
                            "45 And 250 ft",
                            "From The Device",
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: (potentialMessageIndex.value == 2) ? 1 : 0,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Navigation.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          child: Hints(
                            lines: [
                              "You Are Getting Closer",
                            ],
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: (potentialMessageIndex.value == 3) ? 1 : 0,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Navigation.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          child: Hints(
                            lines: [
                              "You Are Getting Further",
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
*/