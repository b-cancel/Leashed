import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leashed/addNew.dart';
import 'package:leashed/deviceFinder.dart';
import 'package:leashed/deviceScanner.dart';
import 'package:leashed/homeHelper/deviceItem.dart';
import 'package:leashed/navigation.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';

import 'dart:math' as math;

class MapWidget extends StatefulWidget {
  final List<String> titles;
  final List<String> subtitles;
  final List<LatLng> locations;

  MapWidget({
    this.titles,
    this.subtitles,
    this.locations,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  CameraPosition targetCameraPosition;

  @override
  void initState(){ 
    super.initState();
    setStartCameraPosition(widget.locations);
    addMarkers(
      widget.titles, 
      widget.subtitles,
      widget.locations,
    );
  }

  setStartCameraPosition(List<LatLng> locations){
    //length shortcut
    int locationsCount = locations.length;

    //keep track of the sums
    double latitude = 0;
    double longitude = 0;

    //make the sums
    for(int i = 0; i < locationsCount; i++){
      latitude += locations[i].latitude;
      longitude += locations[i].longitude;
    }

    //get the average
    LatLng averageLocation = LatLng(
      latitude / locationsCount, 
      longitude / locationsCount,
    );

    //NOTE:
    //1. lat (neg S, pos N) 
    //2. lng (neg W, pos E)

    //make the min max vars
    double mostSouth = locations[0].latitude;
    double mostNorth = locations[0].latitude;
    double mostWest = locations[0].longitude;
    double mostEast = locations[0].longitude;

    //get the min max vars (start @1 since 0 is taken care of)
    for(int i = 1; i < locationsCount; i++){
      double lat = locations[i].latitude;
      double lng = locations[i].longitude;
      mostSouth = (lat < mostSouth) ? lat : mostSouth;
      mostNorth = (lat > mostNorth) ? lat : mostNorth;
      mostWest = (lng < mostWest) ? lng : mostWest;
      mostEast = (lng > mostEast) ? lng : mostEast;
    }

    //use bounds to calculate zoom
    double zoom = 15; //TODO... stop using guessed value

    //set the target postion to the average position
    targetCameraPosition = CameraPosition(
      target: averageLocation,
      zoom: 15, 
    );
  }

  addMarkers(
    List<String> titles, 
    List<String> subtitles,
    List<LatLng> locations,
  ) async {
    final GoogleMapController controller = await Navigation.mapController.future;
    int markerCount = titles.length;
    for(int i = 0; i < markerCount; i++){
      controller.addMarker(
        MarkerOptions(
          consumeTapEvents: false,
          flat: false, //so that the pin stays properly oriented
          infoWindowText: InfoWindowText(
            titles[i], 
            subtitles[i],
          ),
          position: locations[i],
          visible: true,
        )
      );
    }
  }

  goToLocation(CameraPosition newPosition) async {
    final GoogleMapController controller = await Navigation.mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          myLocationEnabled: true, //show your location on the map
          compassEnabled: true,
          mapType: MapType.normal, 
          initialCameraPosition: targetCameraPosition, 
          onMapCreated: (GoogleMapController controller) {
            Navigation.mapController.complete(controller);
          },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IgnorePointer(
                child: FloatingActionButton(
                  heroTag: 'recenterPhone',
                  onPressed: () => print("button behind gets pressed"),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Icon(
                          Icons.location_searching,
                          size: 46,
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Navigation.blueGrey,
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: Icon(
                            Icons.phone_android,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 16,
              ),
              FloatingActionButton(
                heroTag: 'recenterDevice',
                onPressed: (){
                  goToLocation(targetCameraPosition);
                },
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Icon(
                        Icons.location_searching,
                        size: 46,
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Navigation.blueGrey,
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: Icon(
                          Icons.bluetooth,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}