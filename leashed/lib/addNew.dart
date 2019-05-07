import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/deviceFinder.dart';
import 'package:leashed/deviceScanner.dart';
import 'dart:math' as math;

import 'package:leashed/navigation.dart';
import 'package:leashed/recordSignature.dart';
import 'package:leashed/scanner.dart';
import 'package:leashed/widgets/bluetoothOffBanner.dart';
import 'package:page_transition/page_transition.dart';
import 'package:image_picker/image_picker.dart';

//TODO... use image_picker_saver 0.1.0
//to also let users select images from the web

class AddEditDeviceDetails extends StatefulWidget {
  AddEditDeviceDetails({
    this.name,
    this.id,
    this.type,
    this.imageUrl: "",
    this.addDetails: true,
  });

  final String name;
  final String id;
  final String type; 
  final String imageUrl;
  final bool addDetails;

  @override
  _AddEditDeviceDetailsState createState() => _AddEditDeviceDetailsState();
}

class _AddEditDeviceDetailsState extends State<AddEditDeviceDetails> {
  final TextEditingController nameController = new TextEditingController();
  final FocusNode nameFocusNode = new FocusNode();
  final ValueNotifier<bool> editingName = new ValueNotifier<bool>(false); 
  final ValueNotifier<String> deviceImage = new ValueNotifier<String>("");
  final ValueNotifier<bool> imageProvided = new ValueNotifier<bool>(false);
  
  @override
  void initState() {
    //make sure bluetooth is on to stop users from recording the devices signture otherwise
    ScannerStaticVars.bluetoothOn.addListener(customSetState);

    //handle the image
    imageProvided.value = (widget.imageUrl != "");
    if(imageProvided.value){
      deviceImage.value = widget.imageUrl;
    }
    else{
      deviceImage.value = "assets/pngs/devicePlaceholder.png";
    }

    //handle the name
    nameController.text = widget.name;

    //the hanlder for the name being changed
    editingName.addListener((){
      if(editingName.value){
        FocusScope.of(context).requestFocus(nameFocusNode);
      }

      //set state to enable or disable text field
      setState(() {
        
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    ScannerStaticVars.bluetoothOn.removeListener(customSetState);
    super.dispose();
  }

  customSetState()async {
    if(mounted){
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 4;
    double height = MediaQuery.of(context).size.height / 4;
    double imageSize = math.min(width, height);

    return Column(
      children: <Widget>[
        (ScannerStaticVars.bluetoothOn.value)
        ? Container()
        : new BluetoothOff(),
        Expanded(
          child: ListView(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0, bottom: 4),
                            child: new Container(
                              width: imageSize,
                              height: imageSize,
                              child: new Image.asset(
                                deviceImage.value,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: EdgeInsets.only(right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80.0),
                                  color: Navigation.blueGrey,
                                  border: Border.all(
                                    color: Navigation.blueGrey,
                                    width: 4.0,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => imagePicker(),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width - imageSize - (16 * 3),
                            child: Stack(
                              children: <Widget>[
                                TextFormField(
                                  controller: nameController,
                                  focusNode: nameFocusNode,
                                  enabled: editingName.value,
                                  onFieldSubmitted: (str){
                                    nameController.text = str;
                                    editingName.value = false;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(0),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: (){
                                      editingName.value = true;
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text(widget.id),
                                new Text(widget.type),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              (widget.addDetails == false)
              ? Container()
              : InkWell(
                onTap: (){
                  /*
                  Navigator.push(context, PageTransition(
                    type: PageTransitionType.fade,
                    duration: Duration.zero, 
                    child: DeviceScanner(
                      title: "Grabbing Device Signature",
                      child: new LiveScanner( 
                        deviceID: widget.id,
                      ),
                    ),
                  ));
                  */
                },
                child: Container(
                  padding: EdgeInsets.all(64),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.signature,
                        size: 100,
                      ),
                      Text(
                        "Inspect Signal",
                        style: TextStyle(
                          color: Navigation.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void imagePicker(){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          contentPadding: EdgeInsets.all(8),
          content: new Row(
            children: <Widget>[
              bigIcon(true, Icons.camera_alt),
              bigIcon(false, FontAwesomeIcons.images),
            ],
          ),
        );
      }
    );
  }

  Widget bigIcon(bool fromCamera, dynamic icon){
    return Expanded(
      child: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          padding: EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 4),
          child: IconButton(
            onPressed: () => changeImage(fromCamera),
            icon: Icon(icon),
          ),
        ),
      ),
    );
  }

  Future changeImage(bool fromCamera) async {
    File image = null; 
    
    await ImagePicker.pickImage(
      source: (fromCamera) ? ImageSource.camera : ImageSource.gallery,
    );

    if(image != null){
      Navigator.of(context).pop();

      print("not null");

      /*
      var urlMod = widget.appData.url + "/api/v1/my_account/profile_image";
      
      FormData formData = new FormData.from({
        "token": widget.appData.token,
        "image": new UploadFileInfo(image, "profile.jpeg"),
      });

      var response = await dio.patch(
        urlMod, 
        options: Options(
          method: "PATCH",
          headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token},
        ),
        data: formData,
      );

      if (response.statusCode == 200){
        //retreive data from server
        var urlMod = widget.appData.url + "/api/v1/my_account";
        http.get(
          urlMod, 
          headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.appData.token}
        ).then((response){
            if(response.statusCode == 200){ 
              imageUrl.value = jsonDecode(response.body)["profile_image_url"];
            }
            else{ 
              print(urlMod + " get profile fail");
              //TODO... trigger some visual error
            }
        });
      }
      else print("Not Uploaded! " + response.toString());
      */
    }
  }
}