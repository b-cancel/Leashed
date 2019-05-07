import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/searchNew.dart';
import 'package:leashed/settings.dart';
import 'package:page_transition/page_transition.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    this.deviceCount,
    @required this.navBarHeight,
    this.introScreen: false,
  });

  final double navBarHeight;
  final ValueNotifier<int> deviceCount;
  final bool introScreen;

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
          Container(
            padding: EdgeInsets.only(right: 12),
            child: (introScreen)
            ? Icon(
                Icons.settings,
                color: Colors.white.withOpacity(0.5),
            )
            : InkWell(
              child: Icon(
                Icons.settings,
                color: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key key,
    @required this.icons,
    this.names,
    @required this.menuNum,
    @required this.callback,
  }) : super(key: key);

  final List<Widget> icons;
  final List<String> names;
  final ValueNotifier<int> menuNum;
  final Function callback;

  static final Text noText = Text(
    '',
    style: TextStyle(
      fontSize: 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> navItems = new List<BottomNavigationBarItem>();
    bool noNames = (this.names == null);
    for(int i = 0; i < icons.length; i++){
      navItems.add(
        BottomNavigationBarItem(
          icon: icons[i], 
          title: (noNames) 
          ? noText
          : Text(
            names[i],
          ),
        ),
      );
    }

    return Theme(
      data: ThemeData.dark().copyWith(
        canvasColor: Navigation.blueGrey,
      ),
      child: SizedBox(
        height: (noNames) ? 50 : 60,
        child: BottomNavigationBar(
          onTap: callback,
          currentIndex: menuNum.value,
          fixedColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: navItems,
        ),
      ),
    );
  }
}