import 'package:flutter/material.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';

//NOTE: we know for a fact that when we arrive at this widget our bluetooth is on

class RecordSignature extends StatefulWidget {
  final String deviceID;

  const RecordSignature({
    this.deviceID,  
  });

  @override
  _RecordSignatureState createState() => _RecordSignatureState();
}

class _RecordSignatureState extends State<RecordSignature> {
  @override
  void initState() {
    //super init
    super.initState();

    //start the scanner after the first build (the user will instantly see the effect of them pressing the plus)
    WidgetsBinding.instance.addPostFrameCallback((_) => ScannerStaticVars.startScan());

    //Listeners To Determine When to Reload
    ScannerStaticVars.bluetoothOn.addListener(customExit);
    ScannerStaticVars.isScanning.addListener(customSetState);
    ScannerStaticVars.wantToBeScanning.addListener(customSetState); //allows for reset button
  }

  @override
  void dispose(){
    //remove listeners
    ScannerStaticVars.bluetoothOn.removeListener(customExit);
    ScannerStaticVars.isScanning.removeListener(customSetState);
    ScannerStaticVars.wantToBeScanning.removeListener(customSetState); //allows for reset button

    //stop the scanner
    ScannerStaticVars.stopScan();

    //super dispose
    super.dispose();
  }

  //-----BLE Interact START

  customSetState() async {
    if(mounted){
      setState((){});
    }
  }

  customExit() async{
    ScannerStaticVars.stopScan();
    Navigator.of(context).maybePop();
  }

  //-----BLE Interact END

  ///-------------------------Overrides-------------------------
  @override
  Widget build(BuildContext context) {
    //our main widget to return
    return new Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => customExit(),
          child: IgnorePointer(
            child: BackButton(),
          ),
        ),
        title: new Text(
          "Recording Device Signature",
        ),
      ),
      body: new Builder(builder: (BuildContext context) {
        if(ScannerStaticVars.isScanning.value){
          return Container(
            child: Center(
              child: new Text("Scanner is on"),
            ),
          );
        }
        else{
          return InkWell(
            onTap: (){
              //Inform the user that it might fail
              final SnackBar msg = SnackBar(
                content: Text(
                  'Trying To Re-Start The Scanner' 
                  + '\n' 
                  + 'If It Fails Please Try Again',
                ),
              );
              Scaffold.of(context).showSnackBar(msg);
              //Attempt to Start Up The Scanner
              ScannerStaticVars.startScan();
            },
            child: Container(
              child: Center(
                child: new Text("waiting for scanner to turn on"),
              ),
            ),
          );
        }
      }),
      
      
      
      /*new Column(
        children: <Widget>[
          (ScannerStaticVars.bluetoothOn.value)
          ? Container()
          : new BluetoothOffBanner(),
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.black
            ),
            child: Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    ScannerStaticVars.stopScan();
                  } else if (scrollNotification is ScrollEndNotification) {
                    ScannerStaticVars.startScan();
                  }

                  //ScrollUpdateNotification -> get give position and velocity
                  //UserScrollNotification -> user changes scroll direction
                },
                child: ListView.builder(
                  //POTENTIAL OPTIMIZATIONS
                  //maybe ignore pointer in all locations except what is expected
                  //gesture detector instead of inkwell
                  //flutter run --release
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(8.0),
                  itemCount: deviceIDs.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if(index == deviceIDs.length){
                      return new Container(
                        height: 65,
                      );
                    }
                    else{
                      String deviceID = deviceIDs[index];
                      DeviceData device = ScannerStaticVars.allDevicesFound[deviceID];
                      return NewDeviceTile(
                        devices: ScannerStaticVars.allDevicesFound,
                        device: device,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return floatingButton(context);
      }),
      */
    );
  }

  /*
  Widget floatingButton(BuildContext context){
    if(ScannerStaticVars.bluetoothOn.value){
      if(ScannerStaticVars.wantToBeScanning.value){
        if(ScannerStaticVars.isScanning.value){
          return patternDetectionButton();
        }
        else{
          return resetButton(context);
        }
      } //so we dont show the reset button when scrolling
      return Container();
    } //so we dont show either when waiting for the user to start turn onbluetooth
    else return Container();
  }

  Widget patternDetectionButton(){
    return FloatingActionButton.extended(
      onPressed: (){
        ScannerStaticVars.stopScan();
        Navigator.push(context, PageTransition(
          type: PageTransitionType.fade,
          duration: Duration.zero, 
          child: PhoneDown(),
        ));
      },
      icon: new Icon(
        FontAwesomeIcons.questionCircle,
        size: 18,
      ),
      label: new Text(
        "Can't Identify Your Device?",
        style: TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
  */
}