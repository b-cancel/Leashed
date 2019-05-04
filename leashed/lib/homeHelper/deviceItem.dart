import 'package:flutter/material.dart';
import 'package:leashed/devicePages/deviceMap.dart';
import 'package:leashed/navigation.dart';
import 'dart:math' as math;

import 'package:page_transition/page_transition.dart';

class Device extends StatefulWidget {
  final String image;
  final String name;
  final String status;

  Device({
    Key key, 
    this.image,
    this.name,
    this.status,
  }) : super(key: key);

  _DeviceState createState() => _DeviceState();
}

//String image, String name, String status
class _DeviceState extends State<Device> {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 4;
    double height = MediaQuery.of(context).size.height / 4;
    double imageSize = math.min(width, height);

    //TODO... change this to no longer work with placeholders
    String image = "assets/placeholders/" + widget.image;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: (){
            Navigator.push(context, PageTransition(
              type: PageTransitionType.downToUp,
              child: DeviceMap(
                image: image, 
                name: widget.name,
                status: widget.status,
              ),
            ));
          },
          child: new Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //no main axis size
                //no main alignment
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 4),
                      child: new Container(
                        width: imageSize,
                        height: imageSize,
                        child: new Image.asset(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Navigation.blueGrey,
                            ),
                          ),
                          new Text(
                            widget.status,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16),
                    child: Transform.rotate(
                      angle: math.pi / 2,
                      child: new Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(right: (imageSize * 4) * (1/10)),
          child: Divider(
            color: Colors.blueGrey[900],
            height: 2,
          ),
        ),
        Container(
          height: 16,
        ),
      ],
    );
  }
}