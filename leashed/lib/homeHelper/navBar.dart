import 'package:flutter/material.dart';
import 'package:leashed/searchNew.dart';
import 'package:leashed/settings.dart';
import 'package:page_transition/page_transition.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    Key key,
    @required this.warningThickness,
    this.deviceCount,
  }) : super(key: key);

  final double warningThickness;

  final ValueNotifier<int> deviceCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: warningThickness,
      width: MediaQuery.of(context).size.width,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_to_photos,
              color: Colors.white,
            ),
            onPressed: (){
              Navigator.push(context, PageTransition(
                type: PageTransitionType.leftToRight,
                child: SearchNew(),
              ));
            },
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: new Image.asset(
              'assets/pngs/leashedWhite.png',
              fit: BoxFit.fitHeight,
              gaplessPlayback: false,
            ),
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: (){
              Navigator.push(context, PageTransition(
                type: PageTransitionType.rightToLeft,
                child: Settings(),
              ));
            },
            onLongPress: (){ //TODO... remove debug (toggle UI)
              deviceCount.value = (deviceCount.value > 0) ? 0 : 1;
            },
          )
        ],
      ),
    );
  }
}