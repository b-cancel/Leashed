import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/searchNew.dart';
import 'package:leashed/settings.dart';
import 'package:page_transition/page_transition.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    Key key,
    @required this.navBarHeight,
    this.deviceCount,
  }) : super(key: key);

  final double navBarHeight;

  final ValueNotifier<int> deviceCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: navBarHeight,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
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

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key key,
    @required this.menuNum,
    @required this.callback,
  }) : super(key: key);

  final ValueNotifier<int> menuNum;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    Text noText = Text(
      '',
      style: TextStyle(
        fontSize: 0,
      ),
    );

    return Theme(
      data: ThemeData.dark().copyWith(
        canvasColor: Navigation.blueGrey,
      ),
      child: BottomNavigationBar(
        onTap: callback,
        currentIndex: menuNum.value,
        fixedColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list), 
            title: noText,
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.map), 
            title: noText,
          ),
        ],
      ),
    );
  }
}