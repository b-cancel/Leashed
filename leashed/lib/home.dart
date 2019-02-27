import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            title: new Container(
              color: Colors.red,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(child: new Text("left")),
                  Container(child: new Text("center")),
                  Container(child: new Text("right")),
                ],
              ),
            ),
          ),
          new SliverList(
            delegate: new SliverChildBuilderDelegate((context, index){
              return new Container(
                child: new Text("hi"),
              );
            }),
          )
        ],
      ),
    );
  }
}

/*
this.leading,
this.automaticallyImplyLeading = true,
this.title,
this.actions,
this.flexibleSpace,
this.bottom,
this.elevation,
this.forceElevated = false,
this.backgroundColor,
this.brightness,
this.iconTheme,
this.textTheme,
this.primary = true,
this.centerTitle,
this.titleSpacing = NavigationToolbar.kMiddleSpacing,
this.expandedHeight,
this.floating = false,
this.pinned = false,
this.snap = false,
*/