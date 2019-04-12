String durationPrint(dynamic dtOrDur, {bool short = false}){
  //if we pass a datetime we assume
  //we use this time to get a duration
  if(dtOrDur is DateTime){
    dtOrDur = (DateTime.now()).difference(dtOrDur);
  }

  //get all individual values
  int days = dtOrDur.inDays;
  int hours = dtOrDur.inHours;
  int minutes = dtOrDur.inMinutes;
  int seconds = dtOrDur.inSeconds;
  int milliseconds = dtOrDur.inMilliseconds;
  int microseconds = dtOrDur.inMicroseconds;

  //print the largest value
  if(days != 0) return (short) ? "${days}d" : "$days day(s)";
  else if(hours != 0) return (short) ? "${hours}h" : "$hours hour(s)";
  else if(minutes != 0) return (short) ? "${minutes}m" : "$minutes minute(s)";
  else if(seconds != 0) return (short) ? "${seconds}s" : "$seconds second(s)";
  else if(milliseconds != 0) return (short) ? "${milliseconds}l" : "$milliseconds millisec(s)";
  else return (short) ? "${microseconds}i" : "$microseconds microsec(s)";
}

Duration durationAverage(List<Duration> durations){
  int count = durations.length;
  if(count == 0) return Duration.zero;
  else{
    //NOTE: depends on total being able to hold all the microseconds
    Duration sum = Duration.zero;
    //get sum
    for(int i = 0; i < count; i++){
      sum += durations[i];
    }
    //truncations occurs
    //a fraction of a MICROsecond isn't going to make a difference for most applications
    return Duration(microseconds: (sum.inMicroseconds ~/ count));
  }
}

//get new average BEFORE adding newDuration
Duration newDurationAverage(Duration currentAverage, int lastCount, Duration newDuration){
  Duration sum = currentAverage * lastCount;
  sum += newDuration;
  return Duration(microseconds: (sum.inMicroseconds ~/ (lastCount + 1)));
}

double deviation(Duration val, Duration mean, Duration stdDev){
  if(stdDev == Duration.zero) return 0;
  else{
    Duration valMinusMean = val - mean;
    double dev = valMinusMean.inMicroseconds / stdDev.inMicroseconds;
    return dev;
  }
}

String nDigitsBehind(double number, int nDigits){
  String str = number.toString();

  //remove negative
  if(number < 0) str = str.substring(1);

  //remove uneeded precision
  int decIndex = str.indexOf(".");
  if(decIndex != -1){
    String before = str.substring(0, decIndex);
    String after = str.substring(decIndex, str.length - 1);

    //remove or add digits
    int digitsAfter = after.length - 1; //after includes .
    if(digitsAfter != nDigits){
      if(digitsAfter < nDigits){ //add digits
        int digitsNeeded = nDigits - digitsAfter;
        while(digitsNeeded > 0){
          str += "0";
          digitsNeeded--;
        }
      }
      else{ //remove digits
        after = after.substring(0, nDigits + 1);
        str = before + after;
      }
    }
    //ELSE... our string is already of the perfect size
  }

  //add negative
  if(number < 0) return "-" + str;
  else return str;
}

String atleastLengthOfn(int num, int minLength) {
  String numStr = num.toString();
  int added0s = minLength - numStr.length;
  if(num < 0) numStr = numStr.substring(1); //remove the negative sign
  for (int i = added0s; i > 0; i--) numStr = "0" + numStr;
  if(num >= 0) return numStr;
  else return ("-" + numStr);
}