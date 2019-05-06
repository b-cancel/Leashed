import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leashed/addNew.dart';
import 'package:leashed/home.dart';
import 'package:leashed/searchNew.dart';
import 'package:leashed/settings.dart';

//-------------------------Root Widget-------------------------

///This Exists Exclusively to
///(1) create a top level Material App that can be used by the rest of the widgets for navigation
///(2) define a global Route that can be used by the rest of widgets for navigation
///(3) define all potential routes throughout the application

class Navigation extends StatelessWidget {
  static final appRouter = new Router();
  static final Color blueGrey = Colors.blueGrey[900];
  static final ValueNotifier<int> defaultTimeToDetectPattern = new ValueNotifier<int>(5);
  static final ValueNotifier<int> addToTimeToDetectPattern = new ValueNotifier<int>(3);
  static final ValueNotifier<int> timeToDetectPattern = new ValueNotifier<int>(5);

  //used to detect when we come back to
  //1. going back to ourDeviceScan should restart the scan
  //2. going back to newDeviceScan should restart the scan

  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
      theme: ThemeData.light().copyWith(
        primaryColor: blueGrey,
        accentColor: blueGrey,
      ), //TODO... be able to dynamically change theme in settings
      navigatorObservers: [routeObserver],
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
    //NOTE: I can assign transition type here If needed
    /*
    router.define("home", handler: homeHandler);
    router.define("settings", handler: settingsHandler);
    router.define("searchNew", handler: searchNewHandler);
    router.define("addNew", handler: addNewHandler);
    */
  }

  //---------------------Router Handlers--------------------
  /// NOTE: with Fluro you can pass parameters between routes like you do with Ruby

  /*
  final homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return new Home();
    },
  );

  final settingsHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return new Settings();
    },
  );

  final searchNewHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return new SearchNew();
    }
  );

  final addNewHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params)  {
      return new AddNew();
    }
  );
  */
}