import 'package:flutter/material.dart';

import 'package:leashed/sliverModifications/sliverPersistentHeader.dart' as sliverPersistentHeader;
import 'package:leashed/sliverModifications/flexibleSpaceBar.dart' as flexibleSpaceBar;

class HomeStateLess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
  Color bottomOfIntroImage = Color.fromARGB(155, 248, 215, 218);
  Color topOfIntroImage = Color.fromARGB(255, 141, 140, 140);

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
                    color: bottomOfIntroImage,
                  ),
                  Transform.translate(
                    offset: Offset(0, -warningThickness -alignmentPush),
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
                    color: introOverlay,
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
                    Container(
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
                            onPressed: () => print("adding device"),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: new Image.asset(
                                'assets/pngs/leashedWhite.png',
                                fit: BoxFit.fitHeight,
                              ),

                          ),
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () => print("going to settings"),
                          )
                        ],
                      ),
                    ),
                    //----------ERROR
                    Container(
                      color: Colors.red,
                      child: FlatButton(
                        onPressed: () => print("open up bluetooth"),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.warning,
                              ),
                            ),
                            new Text(
                              "Please Tap Here To Turn On Your Bluetooth",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          new SliverList(
            delegate: new SliverChildListDelegate([
              new Container(
                color: Colors.pink,
                height: 250,
                child: new Text("hi"),
              ),
              new Container(
                color: Colors.cyan,
                height: 250,
                child: new Text("hi"),
              ),
              new Container(
                color: Colors.pink,
                height: 250,
                child: new Text("hi"),
              ),
              new Container(
                color: Colors.cyan,
                height: 250,
                child: new Text("hi"),
              ),
              new Container(
                color: Colors.pink,
                height: 250,
                child: new Text("hi"),
              ),
              Container(
                color: Colors.green,
                height: 250,
                child: OverflowBox(
                  alignment: Alignment.bottomCenter,
                  maxHeight: 1000,
                  child: new Container(
                    alignment: Alignment.bottomCenter,
                    height: 750,
                    color: Colors.pink,
                    child: new Image.asset(
                      'assets/pngs/intro.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              new Container(
                color: Colors.cyan,
                height: 250,
                child: new Text("hi"),
              ),
            ]),

            /*      new SliverChildBuilderDelegate((context, index){
              return new Container(
                child: new Text("hi"),
              );
            }),
    */
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
    return (halfHeight - (halfHeight * .25));
  }
}