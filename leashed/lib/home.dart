import 'package:flutter/material.dart';
import 'persistentHeaderDelegate.dart';

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            //---settings
            //TRUE the app bar should be immediately visible when the user starts scrolling towards the top
            floating: true,
            //FALSE lets the bar be scroll away when scrolling to far from view
            pinned: true,
            delegate: PersistentHeader(
              minExtent: 100,
              maxExtent: 200,
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

  //functions within class

}