import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:leashed/addNew.dart';
import 'package:leashed/home.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/searchNew.dart';
import 'package:leashed/settings.dart';

///This Exists Exclusively to
///(1) create a top level Material App that can be used by the rest of the widgets for navigation
///(2) define a global Route that can be used by the rest of widgets for navigation
///(3) define all potential routes throughout the application

//-------------------------Root Widget-------------------------

class Navigation extends StatelessWidget {
  static final appRouter = new Router();
  static final Color blueGrey = Colors.blueGrey[900];

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
    router.define("home", handler: homeHandler);
    router.define("settings", handler: settingsHandler);
    router.define("searchNew", handler: searchNewHandler);
    router.define("addNew", handler: addNewHandler);
  }

  //---------------------Router Handlers--------------------
  /// NOTE: with Fluro you can pass parameters between routes like you do with Ruby

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
}