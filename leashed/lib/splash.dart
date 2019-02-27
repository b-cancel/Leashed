import 'package:flutter/material.dart';

/*
//-----calls our first screen... the Splash Screen
class SplashScreen extends StatefulWidget{
  @override
  _SplashScreen createState() => new _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {

    var _fontStyle = new TextStyle(color: Colors.red, fontSize: 35.0);
    var _logo = new Image.asset('images/BlueLeashLogo.png', fit: BoxFit.cover);

    return new MaterialApp(
        title: 'SplashScreen',
        routes: <String, WidgetBuilder>{
          //'/manLogin': (BuildContext context) => new ManualLogin(),
        },
        home: new SplashScreenHelper()
    );
  }
}

//------------------------------HACK
//Required in order to be able to load up new widgets in different files

class SplashScreenHelper extends StatefulWidget{
  @override
  _SplashScreenHelper createState() => new _SplashScreenHelper();
}

class _SplashScreenHelper extends State<SplashScreenHelper> with SingleTickerProviderStateMixin{

  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
      duration: new Duration(milliseconds: 5000), //total time the animation will take
      vsync: this,
    );

    _animation = new Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener((){
        setState(() {
          //update animation
        });
      });

    _controller.forward();
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
        body: new InkWell(
          //-----Code
          //NOTE: I used to working version of Navigation between different Widgets
          onTap: (){
            /*
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new ManualLogin()),
            );
            */
          },
          onLongPress: (){
            Navigator.of(context).pushNamed('/autoLogin');
          },
          //-----Structure
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Opacity(
                    opacity: _animation.value,
                    child: new Image.asset(
                        'images/BlueLeashLogo.png',
                        fit: BoxFit.cover
                    ),
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}
*/