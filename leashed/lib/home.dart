import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:leashed/homeHelper/deviceItem.dart';
import 'package:leashed/homeHelper/navBar.dart';
import 'package:leashed/homeHelper/noDevices.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';

import 'package:leashed/sliverModifications/sliverPersistentHeader.dart' as sliverPersistentHeader;
import 'package:leashed/sliverModifications/flexibleSpaceBar.dart' as flexibleSpaceBar;
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:leashed/widgets/gradientSlider.dart';

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
  double warningThickness = 40;
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
      warningThickness: warningThickness,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
            backgroundColor: Colors.grey[900],
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
                          Colors.black,
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
                      warningThickness: 40,
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
          new SliverList(
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
          new SliverPadding(
            padding: EdgeInsets.all(16),
          )
        ],
      ),
    );
  }

  double calcMaxExtent(BuildContext context){
    double screenHeight = MediaQuery.of(context).size.height;
    double halfHeight = screenHeight / 2;
    // half is a good size cuz that is realistically what most can access
    // but at the same time just having the image on half the screen isn't going to look great
    return (halfHeight - (halfHeight * (1/5)));
  }
}