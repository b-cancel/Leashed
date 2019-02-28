import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PersistentHeader extends SliverPersistentHeaderDelegate {
  PersistentHeader({
    @required this.minExtent,
    @required this.maxExtent,
    this.snapConfiguration,
  });

  final double minExtent;
  final double maxExtent;
  final FloatingHeaderSnapConfiguration snapConfiguration;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ){
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new Container(
          child: new Text("Image.asset with fit of BoxFit.cover"),
        ),
        new Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black,
              ],
              stops: [0.5, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.repeated,
            ),
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
          child: Text(
            'Hero Image',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant PersistentHeader oldDelegate) {
    //TODO... configure this so if it detects any variable changes then it rebuilds
    return true;
  }
}