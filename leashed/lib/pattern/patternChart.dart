import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;
import 'package:leashed/helper/utils.dart';

class Chart extends StatelessWidget {
  const Chart({
    Key key,
    @required this.scanDateTimes,
    @required this.scanRSSIs,
    @required this.minRSSI,
    @required this.maxRSSI,
    @required this.averageLeft,
    @required this.averageMiddle,
    @required this.averageRight,
    @required this.intervalDateTimes,
    this.showIntervals: false,
  }) : super(key: key);

  final List<DateTime> scanDateTimes;
  final List<int> scanRSSIs;
  final int minRSSI;
  final int maxRSSI;
  final int averageLeft;
  final int averageMiddle;
  final int averageRight;
  final List<DateTime> intervalDateTimes;
  final bool showIntervals;

  @override
  Widget build(BuildContext context) {
    //interval
    List<common.AnnotationSegment> annotations = new List<common.AnnotationSegment>();
    if(showIntervals){
      annotations.addAll(
        createIntervalHighlights(listDateTimeToListInt(intervalDateTimes)),
      );
    }

    //basic intervals
    int endOfLeft = dateTimeToInt(intervalDateTimes[2]);
    int endOfMiddle = dateTimeToInt(intervalDateTimes[4]);

    //range
    int minDateTime = dateTimeToInt(scanDateTimes[0]);
    int maxDateTime = dateTimeToInt(scanDateTimes.last);
    List<int> dateTimes = listDateTimeToListInt(scanDateTimes);

    //expected domain
    print(averageLeft.toString() + " < " + averageMiddle.toString() + " < " + averageRight.toString());
    List<int> expectedRssi = new List<int>();
    for(int i = 0; i < scanRSSIs.length; i++){
      int thisRssiDateTime = dateTimes[i];
      if(thisRssiDateTime < endOfLeft){
        expectedRssi.add(averageLeft);
      }
      else if(thisRssiDateTime < endOfMiddle){
        expectedRssi.add(averageMiddle);
      }
      else{
        expectedRssi.add(averageRight);
      }
    }

    //generate all charts
    List<charts.Series<Data, int>> theCharts = new List<charts.Series<Data, int>>();

    //plot what we received
    theCharts.addAll(
      createCharts(
        dateTimes,
        scanRSSIs,
        [1],
        [charts.MaterialPalette.blue.shadeDefault],
        [10],
      )
    );

    //plot what we expected
    theCharts.addAll(
      createCharts(
        dateTimes,
        expectedRssi,
        [1],
        [charts.MaterialPalette.black],
        [10],
      ),
    );

    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 16, top: 16),
          color: Colors.grey[350],
          child: charts.LineChart(
            theCharts,
            animate: false,
            layoutConfig: charts.LayoutConfig(
              topMarginSpec: charts.MarginSpec.fixedPixel(0),
              rightMarginSpec: charts.MarginSpec.fixedPixel(0),
              bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
              leftMarginSpec: charts.MarginSpec.fixedPixel(0),
            ),
            defaultRenderer: new charts.LineRendererConfig(
              roundEndCaps: false, //makes patterns more clear 
              includePoints: false, //makes patterns more clear
            ),
            behaviors: [
              new charts.RangeAnnotation(
                annotations,
              ),
            ],
            domainAxis: new charts.NumericAxisSpec(
              showAxisLine: false,
              viewport: new charts.NumericExtents(
                minDateTime, 
                maxDateTime,
              ),
              renderSpec: new charts.NoneRenderSpec(),
            ),
            primaryMeasureAxis: new charts.NumericAxisSpec(
              showAxisLine: false,
              viewport: new charts.NumericExtents(
                minRSSI,
                maxRSSI,
              ),
              renderSpec: new charts.NoneRenderSpec(),
            ),
          ),
        ),
      ],
    );
  }
}