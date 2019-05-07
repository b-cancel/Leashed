import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leashed/addNew.dart';
import 'package:leashed/deviceFinder.dart';
import 'package:leashed/deviceScanner.dart';
import 'package:leashed/homeHelper/deviceItem.dart';
import 'package:leashed/homeHelper/navBar.dart';
import 'package:leashed/mapWidget.dart';
import 'package:leashed/scannerUI.dart';

class DeviceDetails extends StatefulWidget {
  final String image;
  final String name;
  final String status;

  DeviceDetails({
    this.image,
    this.name,
    this.status,
  });

  @override
  _DeviceDetailsState createState() => _DeviceDetailsState();
}

class _DeviceDetailsState extends State<DeviceDetails> {
  final ValueNotifier<int> menuNum = ValueNotifier<int>(1);
  final PageController pageController = PageController(
    initialPage: 1,
    keepPage: true,
  );

  @override
  void initState() {
    //set preferred orientation
    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    //super init
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          100, //NOTE: being smaller than the preferred size has no effect
        ),
        child: SafeArea(
          child: Device(
            image: widget.image,
            name: widget.name,
            status: widget.status,
            open: false,
          ),
        ),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (index){
          setState(() {
            menuNum.value = index;
          });
        },
        children: [
          Container(
            color: Colors.white,
            child: ScanStarter(
              child: ScannerUI( 
                deviceID: "0",
              ),
            ),
          ),
          MapWidget(
            titles: [widget.name],
            subtitles: [widget.status],
            locations: [LatLng(26.306134, -98.174892)],
          ),
          Container(
            color: Colors.white,
            child: AddEditDeviceDetails(
              name: widget.name,
              id: "12:42:A5:23:92:12",
              type: "Low Energy",
              imageUrl: "assets/placeholders/" + widget.image,
              addDetails: false,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        icons: [
          Icon(FontAwesomeIcons.signature), 
          Icon(FontAwesomeIcons.map),
          Icon(Icons.settings),
        ],
        names: [
          "Signal",
          "Location",
          "Settings"
        ],
        menuNum: menuNum,
        callback: (int index){
          setState(() {
            menuNum.value = index;
            pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
          });
        },
      ),
    );
  }
}