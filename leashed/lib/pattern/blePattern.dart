import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/deviceScanner.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/pattern/patternIdentify.dart';
import 'package:leashed/scanner.dart';
import 'package:page_transition/page_transition.dart';
import 'package:percent_indicator/percent_indicator.dart' as percent;

//NOTE: we KNOW that 
//1. bluetooth is on
//2. scanning is on
//when we arrive at EITHER of these widgets

class BlePatternPage extends StatelessWidget {
  final int secondsBetweenSteps;
  final int secondsPerStep;
  
  BlePatternPage({
    this.secondsBetweenSteps: 1,
    this.secondsPerStep: 3,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Pattern Recognition"),
        ),
        body: ScanStarter(
          child: BlePattern(
            secondsBetweenSteps: secondsBetweenSteps,
            secondsPerStep: secondsPerStep,
          ),
        ),
      ),
    );
  }
}

class BlePattern extends StatefulWidget {
  final int secondsBetweenSteps;
  final int secondsPerStep;
  
  BlePattern({
    @required this.secondsBetweenSteps,
    @required this.secondsPerStep,
  });

  @override
  _BlePatternState createState() => _BlePatternState();
}

class _BlePatternState extends State<BlePattern> {
  final List<DateTime> intervalTimes = new List<DateTime>();

  @override
  void initState() {
    super.initState();
    //Start the scanner right after all the images load
    //otherwise the images wont load quickly when the device is busy
    WidgetsBinding.instance.addPostFrameCallback((_){
      recursion();
    });
  }

  //-----The Process Variables-----
  int instructionNumber = 1; //starts at 1
  double progressThisStep = 0;

  recursion()async{
    //recursion
    if(instructionNumber > 3){ //base case
      intervalTimes.add(DateTime.now());
      await Future.delayed(Duration(seconds: widget.secondsBetweenSteps));
      intervalTimes.add(DateTime.now());
      if(mounted){
        Navigator.pushReplacement(context, PageTransition(
          type: PageTransitionType.rightToLeft,
          child: PatternIdentify(
            intervalTimes: intervalTimes,
          ),
        ));
      }
    }
    else{ //loop
      intervalTimes.add(DateTime.now());
      await Future.delayed(Duration(seconds: widget.secondsBetweenSteps));
      intervalTimes.add(DateTime.now());
      if(mounted){
        //grab data in this step
        int secondsPerStep = widget.secondsPerStep;
        int secondsTillCompletion = secondsPerStep;
        while(secondsTillCompletion > 0){
          //wait a second
          await Future.delayed(Duration(seconds: 1));
          secondsTillCompletion--;
          if(mounted){
            int timePassed = secondsPerStep - secondsTillCompletion;
            progressThisStep = timePassed / secondsPerStep.toDouble();
            setState(() {});
          }
        }

        //recurse
        instructionNumber++;
        recursion();
      }
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

    //return widget
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            new Step(
              titleHeight: titleHeight, 
              instructString: "To The Right Of", 
              imageSize: imageSize, 
              instructUrl: "assets/pngs/bleRightTurn.png",
            ),
            Opacity(
              opacity: (instructionNumber == 2) ? 1 : 0,
              child: new Step(
                titleHeight: titleHeight, 
                instructString: "Over", 
                imageSize: imageSize, 
                instructUrl: "assets/pngs/bleMiddleTurn.png",
              ),
            ),
            Opacity(
              opacity: (instructionNumber == 1) ? 1 : 0,
              child: new Step(
                titleHeight: titleHeight, 
                instructString: "To The Left Of", 
                imageSize: imageSize, 
                instructUrl: "assets/pngs/bleLeftTurn.png",
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(indicatorPadding, 0, indicatorPadding, 0),
            alignment: Alignment.center,
            child: percent.LinearPercentIndicator(
              animation: false,
              animationDuration: 100,
              animateFromLastPercent: true,
              percent: progressThisStep,
              width: indicatorWidth,
              lineHeight: 16, 
              progressColor: Colors.lightGreenAccent,
            ),
          ),
        )
      ],
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
    return Container(
      color: Colors.white,
      child: Column(
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
      ),
    );
  }
}