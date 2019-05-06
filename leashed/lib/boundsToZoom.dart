  //another with potential
  //https://groups.google.com/forum/#!topic/google-maps-js-api-v3/Q5WHkOr-A38  
  
  /*
  double zoomCalc1(double north, double east, double south, double west){
    //constantly from https://groups.google.com/forum/#!topic/google-maps-js-api-v3/Q5WHkOr-A38
    double constant_at_0_degrees = 1.406245461070741;
    double constant_at_20_degrees = 1.321415085624082;
    double constant_at_40_degrees = 1.077179995861952;
    double constant_at_60_degrees = 0.703119412486786;
    double constant_at_80_degrees = 0.488332580888611;

    //get zoom level
    double width = east - west;
    double height = north - south;
    print("-------------------------width " + width.toString() + " height " + height.toString());

    double dlat = north - south;
    double dlon;
    if(west < east){
      dlon = east - west;
    }
    else{
      dlon = 360 - west + east;
    }
    print("-------------------------dlat " + dlat.toString() + " dlon " + dlon.toString());

    double beforez0 = constant_at_60_degrees * height / dlat;
    double beforez1 = constant_at_60_degrees * width / dlon;
    print("-------------------------beforez0 " + beforez0.toString() + " beforez1 " + beforez1.toString());

    double z0 = math.log(beforez0) / math.ln2; //ceil
    double z1 = math.log(beforez1) / math.ln2; //ceil
    print("-------------------------z0 " + z0.toString() + " z1 " + z1.toString());

    //z1 ? ((z1 > z0) ? z0 : z1) : z0;
    double zoom = (z1 > z0) ? z0 : z1;

    print("-------------------------zoom " + zoom.toString());
    return zoom;
  }
  */

  /*
  double zoomCalc2(double north, double east, double south, double west){
    double width = east - west;
    double height = north - south;
    print("-------------------------width " + width.toString() + " height " + height.toString());
    var dlat = math.abs(bounds.maxY - bounds.minY);
    var dlon = math.abs(bounds.maxX - bounds.minX)
    // Center latitude in radians
    var clat = math.PI*(bounds.minY + bounds.maxY)/360.;
    var C = 0.0000107288;
    double z0 = math.log(dlat/(C*height))/math.ln2;   
    double z1 = math.log(dlon/(C*width*math.cos(clat)))/math.ln2;

    int zoom = (z1 > z0) ? z1 : z0;

    print("-------------------------zoom " + zoom.toString());
    return zoom;
  }

  calcDlat1(){

  }

  calcDlat2(){

  }
  */

  /*
  zoomCalc3(){
    int globeWidth = 256; //a constant in Google's map projection
    double pixelWidth = 1; //TODO... what is this
    var west = LatLng();
    var east = ne.lng();
    LatLng angle = east - west;
    if (angle < 0) {
      angle += 360;
    }
    double zoom = math.log(pixelWidth * 360 / angle / globeWidth) / math.ln2;
  }
  */

  //Super good solution here
  /*
  https://stackoverflow.com/questions/6048975/google-maps-v3-how-to-calculate-the-zoom-level-for-a-given-bounds
  */