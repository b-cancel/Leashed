import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leashed/navigation.dart';
import 'package:leashed/settingsHelper/leashTightness.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:sms/sms.dart';

class Settings extends StatefulWidget { 
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Color lightGrey = Color.fromRGBO(197, 201, 205, .75);
  final Color darkGrey = Colors.grey[900];
  //LIGHT: Color.fromRGBO(237, 240, 242, 1);
  //DARK: Color.fromRGBO(197, 201, 205, 1);

  //message
  final TextEditingController messageField = new TextEditingController();
  final SmsSender sender = new SmsSender();
  final String defaultMessage = "Someone is taking my stuff"
  + "\n" + "I might be unconscious"
  + "\n" + "Please help me"
  + "\n" + "My location is below";
  final ValueNotifier<bool> editingField = new ValueNotifier<bool>(false);

  //contact list
  final ContactPicker contactPicker = new ContactPicker();
  List<Contact> emergencyContacts;
  final Map<int, TableColumnWidth> colWidths = {
    0: IntrinsicColumnWidth(),
    1: IntrinsicColumnWidth(),
    2: FlexColumnWidth(1.0),
  };
  
  @override
  void initState() {
    emergencyContacts = new List<Contact>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Navigation.blueGrey,
        title: new Text("Settings"),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              new SectionLabel(
                lightGrey: lightGrey, 
                darkGrey: darkGrey,
                sectionName: "LEASH TIGHTNESS",
              ),
              new LeashTightness(),
              new SectionLabel(
                lightGrey: lightGrey, 
                darkGrey: darkGrey,
                sectionName: "EMERGENCY MESSAGE",
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16,8,16,8),
                child: new TextField(
                  controller: messageField,
                  onTap: (){
                    editingField.value = true;
                    setState(() {}); //show done button
                  },
                  decoration: InputDecoration(
                    hintText: defaultMessage,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  scrollPadding: EdgeInsets.only(bottom: 64), //For The Done Button
                ),
              ),
              new SectionLabel(
                lightGrey: lightGrey, 
                darkGrey: darkGrey,
                sectionName: "EMERGENCY CONTACTS",
              ),
              Column(
                children: List.generate(emergencyContacts.length, (index){
                  String label = emergencyContacts[index].phoneNumber.label ?? "";
                  if(label != "") label = "(" + label + ")";
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: EdgeInsets.only(right: 16),
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: Icon(FontAwesomeIcons.trashAlt),
                    ),
                    onDismissed: (direction){
                      setState(() {
                        emergencyContacts.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2,
                          )
                        )
                      ),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      emergencyContacts[index].fullName.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(label),
                                  ],
                                ),
                                Text(emergencyContacts[index].phoneNumber.number)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.chevronLeft,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                Container(
                                  width: 4,
                                ),
                                Icon(
                                  FontAwesomeIcons.trash,
                                  color: Colors.grey,
                                  size: 16,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16,8,16,8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new RaisedButton.icon(
                      color: Colors.red,
                      icon: Icon(Icons.warning),
                      label: new Text("Test S.O.S"),
                      onPressed: (){
                        //determine what message to send our contacts
                        String message = messageField.text ?? "";
                        if(message == ""){
                          message = defaultMessage;
                        }

                        //send the message to all of your contacts
                        for(int i = 0; i < emergencyContacts.length; i++){
                          sendTextMessage(
                            emergencyContacts[i].phoneNumber.number, 
                            message,
                          );
                        }
                      },
                    ),
                    new RaisedButton.icon(
                      color: Navigation.blueGrey,
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: new Text(
                        "Add Contact",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        Contact contact = await contactPicker.selectContact();
                        emergencyContacts.add(contact);
                        setState(() {}); //show new contact
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          (editingField.value)
          ? Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              child: RaisedButton(
                color: Navigation.blueGrey,
                onPressed: (){
                  editingField.value = false;
                  //remove focus
                  FocusScope.of(context).requestFocus(new FocusNode());
                  //hide done button
                  setState(() {}); 
                },
                child: new Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          : Container(),
        ],
      ),
    );
  }

  sendTextMessage(String number, String text) async{
    print("sending text to " + number);
    
    //---Collect Message Data
    String basicLink = 'https://www.google.com/maps/search/?api=1&query=';
    /*
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("----- " + position.toString());
    */
    String someCoordinate = '26.27443,-98.1830293';
    String textMessage = text + "\n" + basicLink + someCoordinate;

    

    //---Send The Message
    SmsMessage message = new SmsMessage(
      number, 
      textMessage,
    );
    //To be notified when the message is sent and/or delivered
    /*
    message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        print("SMS is sent!");
      } else if (state == SmsMessageState.Delivered) {
        print("SMS is delivered!");
      }
    });
    */
    //actual send the message
    sender.sendSms(message);
    //To be notified when the message is received
    /*
    sender.onSmsDelivered.listen((SmsMessage message){
      print('${message.address} received your message.');
    });
    */
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    Key key,
    @required this.lightGrey,
    @required this.darkGrey,
    @required this.sectionName,
  }) : super(key: key);

  final Color lightGrey;
  final Color darkGrey;
  final String sectionName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(20,20,8,8),
          decoration: BoxDecoration(
            color: lightGrey,
            border: Border(
              bottom: BorderSide(
                color: darkGrey,
                width: 2,
              ),
            ),
          ),
          child: new Text(
            sectionName,
            style: TextStyle(
              color: darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}