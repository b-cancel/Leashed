import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leashed/homeHelper/deviceItem.dart';
import 'package:leashed/homeHelper/navBar.dart';
import 'package:leashed/homeHelper/noDevices.dart';
import 'package:leashed/mapWidget.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:leashed/widgets/gradientSlider.dart';
import 'package:page_transition/page_transition.dart';

import 'package:leashed/sliverModifications/sliverPersistentHeader.dart' as sliverPersistentHeader;
import 'package:leashed/sliverModifications/flexibleSpaceBar.dart' as flexibleSpaceBar;

import 'dart:math' as math;

//NOTE: so Material App Works properly
class HomeStateLess extends StatelessWidget {
  void initScanner()async {
    ScannerStaticVars.init();
  }

  @override
  Widget build(BuildContext context) {
    initScanner();
    
    //load up the home page
    return Home();
  }
}

class Home extends StatefulWidget{
  @override
  HomeState createState() {
    return new HomeState();
  }
}

class HomeState extends State<Home>  with TickerProviderStateMixin {
  double topNavBarHeight = 40;
  double alignmentPush = 50;
  Color introOverlay = Color.fromARGB(128, 0, 0, 0);
  Color topOfIntroImage = Color.fromARGB(255, 146, 204, 241);
  Color bottomOfIntroImage = Color.fromARGB(255, 141, 140, 140);

  final deviceCount = ValueNotifier<int>(0);

  @override
  void initState() {
    deviceCount.addListener(customSetState);
    super.initState();
  }

  @override
  void dispose() { 
    deviceCount.addListener(customSetState);
    super.dispose();
  }

  customSetState(){
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return (deviceCount.value == 0)
    ? NoDevices(
      topOfIntroImage: topOfIntroImage,
      bottomOfIntroImage: bottomOfIntroImage,
      deviceCount: deviceCount,
    )
    : Devices(
      warningThickness: topNavBarHeight,
      introOverlay: introOverlay,
      bottomOfIntroImage: bottomOfIntroImage,
      alignmentPush: alignmentPush,
      deviceCount: deviceCount,
    );
  }
}

class Devices extends StatefulWidget {
  const Devices({
    Key key,
    @required this.bottomOfIntroImage,
    @required this.warningThickness,
    @required this.alignmentPush,
    @required this.introOverlay,
    this.deviceCount,
  }) : super(key: key);

  final Color bottomOfIntroImage;
  final double warningThickness;
  final double alignmentPush;
  final Color introOverlay;
  final ValueNotifier<int> deviceCount;

  @override
  _DevicesState createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  ValueNotifier<int> menuNum = ValueNotifier<int>(0);
  final ScrollController _scrollController = ScrollController();
  ValueNotifier<bool> visible = ValueNotifier<bool>(true);

  @override
  void dispose() { 
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BottomNavBar bottomNavBar = new BottomNavBar(
      menuNum: menuNum,
      callback: (int index){
        setState(() {
          menuNum.value = index;
          //always show the menu when messing with the map
          if(index == 1) visible.value = true;
        });
      },
    );

    if(menuNum.value == 0){ 
      return Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification){
            bool updateBar = false;
            double minChangeY = .75;

            //Start and Ends does nothing
            //only activate it when its scrolled fast enough (avoids jitter)
            if(scrollNotification is ScrollUpdateNotification){
              //hacked aboslute value
              double changeY;

              //calculate the change
              if(scrollNotification?.dragDetails?.primaryDelta == null){
                changeY = 0;
              }
              else{
                changeY = scrollNotification.dragDetails.primaryDelta.abs();;
              }

              //update
              if(changeY > minChangeY){
                updateBar = true;
              }
            }

            //when on the ends react as well
            if(scrollNotification is OverscrollNotification) updateBar = true;

            //update the bar
            if(updateBar){
              ScrollDirection scrollDirection = _scrollController.position.userScrollDirection;
              if (scrollDirection == ScrollDirection.reverse) {
                setState(() => visible.value = false);
              }

              if (scrollDirection == ScrollDirection.forward) {
                setState(() => visible.value = true);
              }
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              sliverPersistentHeader.MySliverPersistentHeader(
                //---behavior settings
                snap: true,
                pinned: true,
                floating: true,
                //---size settings
                maxExtent: calcMaxExtent(context),
                minExtentAddition:  40, //NOTE: found by simply trying out the app
                //---background that shows up on min
                backgroundColor: Navigation.blueGrey,
                //---background that shows up on max
                flexibleSpace: flexibleSpaceBar.MyFlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Container(
                        color: widget.bottomOfIntroImage,
                      ),
                      Transform.translate(
                        offset: Offset(0, -widget.warningThickness -widget.alignmentPush),
                        child: OverflowBox(
                          alignment: Alignment.bottomCenter,
                          maxHeight: 1000,
                          child: new Container(
                            alignment: Alignment.bottomCenter,
                            height: 1000,
                            color: Colors.pink,
                            child: new Image.asset(
                              'assets/pngs/intro2.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      new Container(
                        color: widget.introOverlay,
                      ),
                      new Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Navigation.blueGrey,
                            ],
                            stops: [0.0, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            tileMode: TileMode.repeated,
                          ),
                        ),
                      ),
                    ],
                  ),
                  collapseMode: flexibleSpaceBar.CollapseMode.pin,
                  title: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        //---------Nav Bar (24 size, with 8 padding on both sides)
                        NavBar(
                          navBarHeight: 40,
                          deviceCount: widget.deviceCount,
                        ),
                        //---------Error
                        (ScannerStaticVars.bluetoothOn.value)
                        ? Container()
                        : BluetoothOffBanner(),
                        //----------Slider
                        new EntireSlider(),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: new SliverChildListDelegate([
                  Device(
                    image: "laptop.jpg", 
                    name: "Laptop", 
                    status:"In Range: 3m away",
                  ),
                  Device(
                    image: "keys.jpg", 
                    name: "Keys", 
                    status: "Last Seen: 2/28/19",
                  ),
                  Device(
                    image: "wallet.jpg", 
                    name: "Wallet", 
                    status: "Waiting at: 1322 Cage St.",
                  ),
                  Device(
                    image: "headphones.jpg", 
                    name: "Headphones", 
                    status: "Turned off: on 2/14/19",
                  ),
                  Device(
                    image: "backpack.jpg", 
                    name: "Backpack", 
                    status: "In Range: 1m away",
                  ),
                ]),
              ),
            ],
          ),
        ),
        bottomNavigationBar: (visible.value) ?  bottomNavBar : SizedBox(),
      );
    }
    else{
      return Scaffold(
        appBar: new AppBar(
          title: NavBar(
            navBarHeight: 40,
            deviceCount: widget.deviceCount,
          ),
        ),
        body: MapWidget(
          titles: [
            "Headphones", 
            "Work Back Pack", 
            "Ditto Tracker",
          ],
          subtitles: [
            "Last Seen at: UTRGV Library", 
            "Last Seen: 8 hrs ago", 
            "In Range: 1-2 meters away",
          ],
          locations: [
            LatLng(26.306773, -98.173589),
            LatLng(26.278324, -98.179618),
            LatLng(26.306134, -98.174892),
          ],
        ),
        bottomNavigationBar: bottomNavBar,
      );
    }
  }

  double calcMaxExtent(BuildContext context){
    double screenHeight = MediaQuery.of(context).size.height;
    double halfHeight = screenHeight / 2;
    // half is a good size cuz that is realistically what most can access
    // but at the same time just having the image on half the screen isn't going to look great
    return (halfHeight - (halfHeight * (1/5)));
  }
}