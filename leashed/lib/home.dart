import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:leashed/helper/utils.dart';
import 'package:leashed/manualLib/flutter_xlider.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';

import 'dart:math' as math;

import 'package:leashed/sliverModifications/sliverPersistentHeader.dart' as sliverPersistentHeader;
import 'package:leashed/sliverModifications/flexibleSpaceBar.dart' as flexibleSpaceBar;
import 'package:leashed/widgets/bluetoothOffBanner.dart';

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
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      animation: deviceCount,
      builder: (context, child){
        if(deviceCount.value == 0){
          return NoDevices(
            topOfIntroImage: topOfIntroImage,
            bottomOfIntroImage: bottomOfIntroImage,
            deviceCount: deviceCount,
          );
        }
        else{
          return Devices(
            warningThickness: warningThickness,
            introOverlay: introOverlay,
            bottomOfIntroImage: bottomOfIntroImage,
            alignmentPush: alignmentPush,
            deviceCount: deviceCount,
          );
        }
      },
    );
  }
}

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
          warningThickness: 40,
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

    double screenWidth = MediaQuery.of(context).size.width;
    print("Screen Width: " + screenWidth.toString());

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

class EntireSlider extends StatelessWidget {
  const EntireSlider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Stack(
        children: <Widget>[
          new SliderBackground(
            height: 24,
            padding: EdgeInsets.fromLTRB(8,16,8,16),
          ),
          Positioned.fill(
            child: Slider(
              rightPadding: 0,
              shiftUp: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class Slider extends StatelessWidget {
  final double rightPadding;
  final double shiftUp;

  const Slider({
    this.rightPadding,
    this.shiftUp,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -shiftUp),
      child: Container(
        padding: EdgeInsets.only(right: rightPadding),
        child: FlutterSlider(
          min: 1,
          max: 4,
          values: [1,2,3,4],
          handler: FlutterSliderHandler(
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              decoration: new BoxDecoration(
                color: Navigation.blueGrey,
                borderRadius: BorderRadius.circular(10),
                border: new Border.all(
                  color: Colors.white,
                ),
              ),
              child: Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
          handlerWidth: 25,
          handlerHeight: 45,
          jump: true,
          onDragging: (handlerIndex, lowerValue, upperValue) {
            print("value: " + lowerValue.toString());
            /*
            setState(() {});
            */
          },
          tooltip: noFlutterSlideTooltip(),
          trackBar: FlutterSliderTrackBar(
            activeTrackBarColor: Colors.red.withOpacity(0),
            inactiveTrackBarColor: Colors.blue.withOpacity(0),
          ),
          /*
          handlerAnimation: FlutterSliderHandlerAnimation(
            curve: Curves.elasticOut,
            reverseCurve: Curves.bounceIn,
            duration: Duration(milliseconds: 500),
            scale: 1.5
          ),
          */
          //NO HatchMark
        ),
      ),
    );
  }
}

class SliderBackground extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;

  const SliderBackground({
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: padding,
      width: MediaQuery.of(context).size.width,
      height: height.toDouble() + padding.vertical,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new ColorSegment(
              color: Colors.black,
            ),
            new GradientSegment(
              left: Colors.black,
              right: Colors.red,
            ),
            new ColorSegment(
              color: Colors.red,
            ),
            new GradientSegment(
              left: Colors.red,
              right: Colors.yellow,
            ),
            new ColorSegment(
              color: Colors.yellow,
            ),
            new GradientSegment(
              left: Colors.yellow,
              right: Colors.green,
            ),
            new ColorSegment(
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class ColorSegment extends StatelessWidget {
  final Color color;

  const ColorSegment({
    this.color,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
      )
    );
  }
}

class GradientSegment extends StatelessWidget {
  final Color left;
  final Color right;

  const GradientSegment({
    this.left,
    this.right,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [left, right], // whitish to gray
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
      ),
    );
  }
}

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
      children: <Widget>[
      ListTile(
        isThreeLine: true,
        contentPadding: EdgeInsets.fromLTRB(16,0,16,16),
        leading: new Container(
          color: Navigation.blueGrey,
          width: imageSize,
          height: imageSize,
          child: new Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
        title: new Text(
          widget.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: new Text(
          widget.status,
          style: TextStyle(
            fontSize: 18,
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
              print("-------------------------Searching For New");
              Navigation.appRouter.navigateTo(context, "searchNew", transition: TransitionType.inFromLeft);
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
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: (){
              //toggle UI
              deviceCount.value = (deviceCount.value > 0) ? 0 : 1;
              //Navigation.appRouter.navigateTo(context, "settings", transition: TransitionType.inFromBottom);
            },
          )
        ],
      ),
    );
  }
}