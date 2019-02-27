import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'splash.dart';

///This Exists Exclusively to
///(1) create a top level Material App that can be used by the rest of the widgets for navigation
///(2) define a global Route that can be used by the rest of widgets for navigation
///(3) define all potential routes throughout the application

//-------------------------Root Widget-------------------------

class Navigation extends StatelessWidget {
  //constructor
  /*
  Navigation() {
    final appRouter = new Router();
    Routes.configureRoutes(appRouter);
    Application.router = appRouter;
  }
  */

  //build app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leashed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), //TODO... be able to dynamically change theme in settings
      //onGenerateRoute: Application.router.generator,
      home: new Container(
        child: new Text("asdfsafsdafadsf"),
      ),

      // new SplashScreen(),
    );
  }
}
/*

//-------------------------Routes-------------------------

class Application {
  static Router router;
}

//-------------------------Routes-------------------------

class Routes {
  static void configureRoutes(Router router) {
    //----make sure we have a valid router
    router.notFoundHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        print("ERROR Router Not Found");
      },
    );

    //-----define the different routes within the router
    router.define("splash", handler: splashScreenHandler);
  }
}

//---------------------Router Handlers--------------------

var splashScreenHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return new SplashScreen();
    },
);
*/