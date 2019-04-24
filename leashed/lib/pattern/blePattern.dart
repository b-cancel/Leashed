import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leashed/helper/structs.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/widgets/instruction.dart';
import 'package:percent_indicator/percent_indicator.dart' as percent;
import 'package:percent_indicator/linear_percent_indicator.dart' as linearPercent;

class BlePattern extends StatefulWidget {
  final Map<String, DeviceData> allDevicesFound;
  final List<DateTime> scanDateTimes;
  final int secondsBetweenSteps;
  final int secondsPerStep;

  BlePattern({
    @required this.allDevicesFound,
    @required this.scanDateTimes,
    this.secondsBetweenSteps: 2,
    this.secondsPerStep: 5,
  });

  @override
  _BlePatternState createState() => _BlePatternState();
}

class _BlePatternState extends State<BlePattern> {
  int stepNumber = 1;
  double progressThisStep = 0;

  @override
  void initState() {
    super.initState();
    process();
  }

  process() async{
    await step(); //1->2 | 2->3 | 3->4
    if(stepNumber <= 3){
      process();
    }
    else{
      await Future.delayed(Duration(seconds: widget.secondsBetweenSteps));
      if(mounted){
        Navigation.appRouter.navigateTo(
          context, 
          "addNew", 
          transition: TransitionType.inFromBottom, 
          replace: true,
        );
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
    switch(stepNumber){
      case 1: 
        instructString = "To The Left Of"; 
        instructUrl = "assets/pngs/bleLeftTurn.png";
        break;
      case 2: 
        instructString = "Over"; 
        instructUrl = "assets/pngs/bleMiddleTurn.png";
        break;
      default: 
        instructString = "To The Right Of"; 
        instructUrl = "assets/pngs/bleRightTurn.png";
        break;
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