import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;
import 'package:leashed/helper/utils.dart';

class Chart extends StatelessWidget {
  const Chart({
    Key key,
    @required this.scanDateTimes,
    @required this.scanRSSIs,
    @required this.intervalDateTimes,
  }) : super(key: key);

  final List<DateTime> scanDateTimes;
  final List<int> scanRSSIs;
  final List<DateTime> intervalDateTimes;

  @override
  Widget build(BuildContext context) {

    //---Min Max RSSIs
    int minValue = scanRSSIs[0];
    int maxValue = scanRSSIs[0];
    for(int i = 1; i < scanRSSIs.length; i++){
      int thisValue = scanRSSIs[i];
      if(thisValue < minValue){
        minValue = thisValue;
      }
      if(thisValue > maxValue){
        maxValue = thisValue;
      }
    }
    int range = maxValue - minValue;

    //---Enforce Min Max Range (DONT USE PARAM MIN MAX)
    int minRange = 2;
    int maxRange = 25;
    if(range < minRange) range = minRange;
    if(range > maxRange) range = maxRange;

    return Stack(
      children: <Widget>[
        Container(
          child: new Text("chart will be here"),
          
          /*charts.LineChart(
            createCharts(
              scanDateTimes,
              scanRSSIs,
              [1,3,7],
            ),
            animate: false,
            defaultRenderer: new charts.LineRendererConfig(
              roundEndCaps: false, //makes patterns more clear 
              includePoints: false, //makes patterns more clear
            ),
            behaviors: [
              new charts.PanAndZoomBehavior(),
              /*
              new charts.SeriesLegend(
                entryTextStyle: charts.TextStyleSpec(
                  color: charts.MaterialPalette.white,
                )
              ),
              */
              new charts.RangeAnnotation(
                annotations,
              ),
            ],
            domainAxis: new charts.NumericAxisSpec(
              showAxisLine: false,
              viewport: new charts.NumericExtents(
                scanDateTimes.first, 
                scanDateTimes.last,
              ),
              renderSpec: new charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  //fontSize: 12,
                  color: charts.MaterialPalette.white,
                ),
              ),
            ),
            primaryMeasureAxis: new charts.NumericAxisSpec(
              showAxisLine: false,
              viewport: new charts.NumericExtents(
                minValue, 
                maxValue,
              ),
              renderSpec: charts.GridlineRendererSpec(
                lineStyle: charts.LineStyleSpec(
                  dashPattern: [4, 4],
                ),
                labelStyle: charts.TextStyleSpec(
                  //fontSize: 12,
                  color: charts.MaterialPalette.white,
                ),
              ),
              tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                //zeroBound: false, //BREAKS STUFF
                //dataIsInWholeNumbers: true, //our running averages may be floats
                desiredTickCount: range,
              ),
            ),
          ),
          */
        ),
      ],
    );
  }

  List<common.AnnotationSegment> createTapHighlights(
    List<int> x,
    List<int> y,
    int lastX,
  ){
    List<common.AnnotationSegment> ranges = new List<common.AnnotationSegment>();
    charts.Color shade = charts.MaterialPalette.gray.shade600;
    for(int i = 0; i < (y.length - 1); i++){
      int thisX = x[i];
      int nextX = i + 1;

      //add to list
      ranges.add(
        new charts.RangeAnnotationSegment(
          thisX, 
          nextX, 
          charts.RangeAnnotationAxisType.domain,
          color: shade,
        )
      );
    }
    return ranges;
  }
}