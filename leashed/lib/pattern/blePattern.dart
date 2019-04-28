import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/pattern/patternIdentify.dart';
import 'package:leashed/scanner.dart';
import 'package:page_transition/page_transition.dart';
import 'package:percent_indicator/percent_indicator.dart' as percent;

class BlePattern extends StatefulWidget {
  final int secondsBetweenSteps;
  final int secondsPerStep;

  BlePattern({
    this.secondsBetweenSteps: 2,
    this.secondsPerStep: 5,
  });

  @override
  _BlePatternState createState() => _BlePatternState();
}

class _BlePatternState extends State<BlePattern> {

  @override
  void initState() {
    super.initState();
    ScannerStaticVars.bluetoothOn.addListener(customSetState);

    //Start the scanner right after all the image load
    //otherwise the images wont load quickly when the device is busy
    WidgetsBinding.instance.addPostFrameCallback((_){
      print("----LOADED");
      ScannerStaticVars.startScan();
    });

    //BEGIN DATA ANALYSIS (done below)
    process(); 
  }

  @override
  void dispose(){
    ScannerStaticVars.bluetoothOn.removeListener(customSetState);
    ScannerStaticVars.stopScan();
    super.dispose();
  }

  customSetState(){
    if(ScannerStaticVars.bluetoothOn.value == false){
      Navigator.of(context).pop(); 
    }
  }

  //-----The Process-----

  int stepNumber = 1;
  double progressThisStep = 0;

  process() async{
    await step(); //1->2 | 2->3 | 3->4
    if(stepNumber <= 3){
      process();
    }
    else{
      await Future.delayed(Duration(seconds: widget.secondsBetweenSteps));
      if(mounted){
        Navigator.pushReplacement(context, PageTransition(
          type: PageTransitionType.fade,
          duration: Duration.zero, 
          child: PatternIdentify(),
        ));
      }
    }
  }

  step() async{ //should add to step number
    //wait until the user processes the command
    await Future.delayed(Duration(seconds: widget.secondsBetweenSteps));
    if(mounted){
      //grab data in this step
      int secondsPerStep = widget.secondsPerStep;
      int timeTillCompletion = secondsPerStep;
      while(timeTillCompletion > 0){
        //wait a second
        await Future.delayed(Duration(seconds: 1));
        if(mounted){
          timeTillCompletion--;

          //inform the user of the progress
          int timePassed = secondsPerStep - timeTillCompletion;
          progressThisStep = timePassed / secondsPerStep.toDouble();
          print("progress: " + progressThisStep.toString());
          setState(() {});
        }
      }

      //move onto the next step
      stepNumber++;
    }
  }

  @override
  Widget build(BuildContext context) {
    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    
    //get size
    double imageSize = MediaQuery.of(context).size.width;
    double titleHeight = (MediaQuery.of(context).size.height - imageSize) / 2;
    double indicatorPadding = 16;
    double indicatorWidth = imageSize - (indicatorPadding * 2);

    //instruction
    String instructString;
    String instructUrl;

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
            Stack(
              children: <Widget>[
                Opacity(
                  opacity: (stepNumber == 1) ? 1 : 0,
                  child: new Step(
                    titleHeight: titleHeight, 
                    instructString: "To The Left Of", 
                    imageSize: imageSize, 
                    instructUrl: "assets/pngs/bleLeftTurn.png",
                  ),
                ),
                Opacity(
                  opacity: (stepNumber == 2) ? 1 : 0,
                  child: new Step(
                    titleHeight: titleHeight, 
                    instructString: "Over", 
                    imageSize: imageSize, 
                    instructUrl: "assets/pngs/bleMiddleTurn.png",
                  ),
                ),
                Opacity(
                  opacity: (stepNumber == 3) ? 1 : 0,
                  child: new Step(
                    titleHeight: titleHeight, 
                    instructString: "To The Right Of", 
                    imageSize: imageSize, 
                    instructUrl: "assets/pngs/bleRightTurn.png",
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(indicatorPadding, 0, indicatorPadding, 0),
                alignment: Alignment.center,
                child: percent.LinearPercentIndicator(
                  animation: true,
                  animationDuration: 100,
                  animateFromLastPercent: true,
                  percent: progressThisStep,
                  width: indicatorWidth,
                  lineHeight: 16, 
                  progressColor: Colors.lightGreenAccent,
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Step extends StatelessWidget {
  const Step({
    Key key,
    @required this.titleHeight,
    @required this.instructString,
    @required this.imageSize,
    @required this.instructUrl,
  }) : super(key: key);

  final double titleHeight;
  final String instructString;
  final double imageSize;
  final String instructUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: titleHeight,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Navigation.blueGrey,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Hold Your Device"),
                Text(
                  instructString,
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
                Text("Your Phone")
              ],
            ),
          ),
        ),
        Container(
          height: imageSize,
          width: imageSize,
          child: Image.asset(instructUrl),
        ),
      ],
    );
  }
}