import 'package:flutter/material.dart';
import 'package:leashed/homeHelper/navBar.dart';
import 'package:leashed/navigation.dart';

class NoDevices extends StatelessWidget {
  const NoDevices({
    Key key,
    @required this.bottomOfIntroImage,
    @required this.topOfIntroImage,
    this.deviceCount,
  }) : super(key: key);

  final Color bottomOfIntroImage;
  final Color topOfIntroImage;
  final ValueNotifier<int> deviceCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        titleSpacing: 0,
        backgroundColor: Navigation.blueGrey,
        title: NavBar(
          navBarHeight: 40,
          deviceCount: deviceCount,
        ),
      ),
      body: new Container(
        color: Colors.red,
        child: new OrientationBuilder(
          builder: (context, orientation) {
            if(orientation == Orientation.portrait){
              return Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: topOfIntroImage,
                    ),
                  ),
                  Image.asset(
                    'assets/pngs/intro2.png',
                    fit: BoxFit.fitWidth,
                  ),
                  Expanded(
                    child: Container(
                      color: bottomOfIntroImage,
                    ),
                  ),
                ],
              );
            }
            else{
              return Container(
                color: topOfIntroImage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Image.asset(
                      'assets/pngs/introLeftPanel.png',
                      fit: BoxFit.fitHeight,
                    ),
                    Image.asset(
                      'assets/pngs/intro2.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}