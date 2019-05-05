import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leashed/addNew.dart';
import 'package:leashed/deviceFinder.dart';
import 'package:leashed/deviceScanner.dart';
import 'package:leashed/homeHelper/deviceItem.dart';
import 'package:leashed/navigation.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';

class DeviceMap extends StatefulWidget {
  final String image;
  final String name;
  final String status;

  DeviceMap({
    this.image,
    this.name,
    this.status,
  });

  @override
  _DeviceMapState createState() => _DeviceMapState();
}

class _DeviceMapState extends State<DeviceMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final CameraPosition deviceLocation = CameraPosition(
    target: LatLng(26.306288, -98.174838),
    zoom: 14.4746,
  );

  @override
  void initState() {
    addMarkers();
    super.initState();
  }

  Future<void> addMarkers() async {
    final GoogleMapController controller = await _controller.future;
    controller.addMarker(
      MarkerOptions(
        consumeTapEvents: false,
        flat: false, //so that the pin stays properly oriented
        infoWindowText: InfoWindowText(
          widget.name, 
          widget.status,
        ),
        position: deviceLocation.target,
        visible: true,
      )
    );
  }

  Future<void> goToLocation(CameraPosition newPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Device(
                image: widget.image,
                name: widget.name,
                status: widget.status,
                open: false,
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
                      myLocationEnabled: true, //show your location on the map
                      compassEnabled: true,
                      mapType: MapType.normal, 
                      initialCameraPosition: deviceLocation, 
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
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
                              goToLocation(deviceLocation);
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*
Positioned(
                      bottom: 8,
                      left: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FloatingActionButton(
                            heroTag: 'signalAnalysis',
                            onPressed: (){
                              Navigator.push(context, PageTransition(
                                type: PageTransitionType.fade,
                                duration: Duration.zero, 
                                child: DeviceScanner(
                                  title: "Device Scanner",
                                  child: new UpdatingScanner( 
                                    deviceID: "0",
                                  ),
                                ),
                              ));
                            },
                            child: Icon(FontAwesomeIcons.signature), //signature //signal
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton(
                        heroTag: 'addNew',
                        onPressed: (){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft,
                              duration: Duration.zero, 
                              child: AddNew(
                                name: widget.name,
                                id: "12:42:A5:23:92:12",
                                type: "Low Energy",
                                imageUrl: "assets/placeholders/" + widget.image,
                                newDevice: false,
                              ),
                            ));
                        },
                        child: Icon(Icons.settings),
                      ),
                    ),
*/