import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:leashed/home.dart';

///This Exists Exclusively to
///(1) create a top level Material App that can be used by the rest of the widgets for navigation
///(2) define a global Route that can be used by the rest of widgets for navigation
///(3) define all potential routes throughout the application

//-------------------------Root Widget-------------------------

class Navigation extends StatelessWidget {
  static final appRouter = new Router();

  //-------------------------Overrides-------------------------

  //init app
  Navigation() {
    configureRoutes(appRouter);
  }

  //build app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leashed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), //TODO... be able to dynamically change theme in settings
      onGenerateRoute: appRouter.generator,
      home: new HomeStateLess(),
    );
  }

  //-------------------------Routes-------------------------

  void configureRoutes(Router router) {
    //----make sure we have a valid router
    router.notFoundHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        print("ERROR Router Not Found");
      },
    );

    //-----define the different routes within the router
    router.define("home", handler: homeHandler); //TODO... define TransitionType IF needed
  }

  //---------------------Router Handlers--------------------
  /// NOTE: with Fluro you can pass parameters between routes like you do with Ruby

  var homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return new Home();
    },
  );
}