import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leashed/addNew.dart';
import 'package:leashed/deviceFinder.dart';
import 'package:leashed/deviceScanner.dart';
import 'package:leashed/homeHelper/deviceItem.dart';
import 'package:leashed/navigation.dart';
import 'package:page_transition/page_transition.dart';

class DeviceMap extends StatelessWidget {
  final String image;
  final String name;
  final String status;

  DeviceMap({
    this.image,
    this.name,
    this.status,
  });

  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Device(
                image: image,
                name: name,
                status: status,
                open: false,
              ),
              Expanded(
                child: GoogleMap(
                  myLocationEnabled: true, //show your location on the map
                  compassEnabled: true,
                  mapType: MapType.normal, 
                  initialCameraPosition: _kGooglePlex, 
                  onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /*
                FloatingActionButton(
                  heroTag: 'back',
                  mini: true,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: BackButtonIcon(), //signature //signal
                ),
                Container(
                  height: 16,
                ),
                */
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
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'addNew',
              onPressed: (){
                Navigator.push(context, PageTransition(
                    type: PageTransitionType.rightToLeft,
                    duration: Duration.zero, 
                    child: AddNew(
                      name: name,
                      id: "12:42:A5:23:92:12",
                      type: "Low Energy",
                      imageUrl: "assets/placeholders/" + image,
                      newDevice: false,
                    ),
                  ));
              },
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}