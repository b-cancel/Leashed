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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          sliverPersistentHeader.MySliverPersistentHeader(
            snap: true,
            pinned: true,
            floating: true,
            expandedHeight: 250,
            flexibleSpace: flexibleSpaceBar.MyFlexibleSpaceBar(
              background: Container(
                color: Colors.pink,
                child: new Text("pink"),
              ),
              collapseMode: flexibleSpaceBar.CollapseMode.none,
              title: Container(
                //color: Colors.red,
                child: new Text("space bar"),
              ),
            ),
          ),
          /*
          SliverPersistentHeader(
            //---settings
            /// NOTE: both true causes the top bar to shift from the top in IOS [GROSS]
            //TRUE the app bar should be immediately visible when the user starts scrolling towards the top
            floating: false,
            //NOTE: always TRUE since this bar also tells you to turn on bluetooth
            //that should always be onscreen when it is required
            pinned: true,

            delegate: PersistentHeader(
              minExtent: 50,
              maxExtent: 350
            ),
          ),
          */
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
}