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