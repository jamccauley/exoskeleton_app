import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }
}

//declarations
String exercise;
String pushedExercise;
bool exerciseStarted = false;
bool exerciseComplete = false;
List<String> dbList = ["Elbow Abduction", "Elbow Adduction", "Shoulder Abduction", "Shoulder Adduction", "Elbow Abduction 2"];
BluetoothDevice passedDevice;
BluetoothSetup blue = new BluetoothSetup();


class BluetoothSetup {
  FlutterBlue bluetooth = FlutterBlue.instance;
  StreamSubscription scanSubscription;
  BluetoothDevice _device;
  List<BluetoothService> services;

  deviceScan() async{
    scanSubscription = bluetooth.scan().listen((scanResult) {
      _device = scanResult.device;
      print(_device.name);

      if (_device.name == 'BlunoMega') {
        scanSubscription.cancel();
        connect(_device);
      }
    });
  }

  connect(BluetoothDevice _device) async{
    scanSubscription.cancel();
    await _device.connect();

    passedDevice = _device;

    findServices();
  }

  deviceDisconnect(_device) {
    _device.disconnect;
  }

  findServices() async {
    services = await _device.discoverServices();
    services.forEach((service){
      print(service.uuid);
    });
    return services;
  }

  sendData(List<int> data) async{
    List<BluetoothCharacteristic> c = services[3].characteristics;

    await c[0].write(data);
  }

}

//main boot screen
void main() {
runApp(MaterialApp(
  title: "Exoskeleton Application",
  initialRoute: '/',
  routes: {
    '/': (context) => Homepage(),
    '/InProgress': (context) => InProgress(),
    '/EndEarly': (context) => EndEarly(),
    '/Metrics': (context) => Metrics(),
    '/Bluetooth': (context) => Bluetooth(),
    },
  ));
}

//home page state reference
class Homepage extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

//Exercise in progress state reference
class InProgress extends StatefulWidget {
  @override
  ExerciseState createState() => new ExerciseState();
}

//end early warning screen state reference
class EndEarly extends StatefulWidget {
  @override
  ExerciseEndState createState() => new ExerciseEndState();
}

//Metrics page state reference
class Metrics extends StatefulWidget {
  @override
  MetricsState createState() => new MetricsState();
}

class Bluetooth extends StatefulWidget {
  @override
  BluetoothState createState() => new BluetoothState();
}

//HomeState state definer
class HomeState extends State<Homepage> {

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);

    return Scaffold(
        appBar: AppBar( //menu bar for the app, holds the nav drawer and can also contain text and all that
          elevation: 0, //elevation zero to eliminate the tacky drop shadow...
        ),
        drawer: Drawer( //navigation drawer, its the hamburger widget
          child: ListView( //define a list within the nav drawer
            children: <Widget>[
              UserAccountsDrawerHeader( //user account drawer; header pre-formatted
                accountName: Text("Sample User"),
                accountEmail: Text("sampleuser@mix.wvu.edu"),
                currentAccountPicture: CircleAvatar( //define the user avatar shape
                  backgroundColor: Colors.grey,
                  child: Text( //text inside the user avatar
                    "U",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
              ListTile( //list item, has interactivity and everything else
                title: Text("View Exercises"),
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
              ListTile(
                title: Text("View Exercise Metrics"),
                onTap: () {
                  Navigator.pushNamed(context, '/Metrics');
                },
              ),
              ListTile(
                title: Text("Bluetooth Settings"),
                onTap: () {
                  Navigator.pushNamed(context, '/Bluetooth');
                },
              )
            ],
          ),
        ),
        backgroundColor: Color.fromRGBO(0,40,85, 1.0),
        //body: RefreshIndicator(
            //onRefresh: E.refresh(),
            body: SingleChildScrollView( //define the scrollview, may need to switch to a list view at some point to enable reloading of new exercises
                child: Column( //define the main column
                  children: <Widget>[
                    //not sure why this widget is here, maybe to make all children of the scroll view interactive??
                    for(var i = 0; i < dbList.length; i++) //using .all ...
                      Padding( //padding for second row
                          padding: const EdgeInsets.all(12),
                          child: Row( //second row
                            children: <Widget>[
                              Container(//second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
                                height: SizeConfig.blockSizeVertical*14,
                                width: SizeConfig.blockSizeHorizontal*94,
                                child: FlatButton( //using the flat button class, simple interactive text based buttons
                                textColor: Color.fromRGBO(0,40,85, 1.0),
                                color: Color.fromRGBO(234, 170, 0, 1.0),
                                child: Text( //defining the text within the button
                                  dbList[i],
                                  style: TextStyle(fontSize: 32),
                                ),
                                onPressed: () => onExerButtonPressed(dbList[i])//onpressed for the exercise selection
                              ),
                              )
                            ],
                          )
                      ),
                  ],
                )
            )
      //  )
    );
  }

  void onExerButtonPressed (String selectedExercise){
    pushedExercise = selectedExercise;
    Navigator.pushNamed(context, '/InProgress');
  }

}

//Exercise in progress state definer
class ExerciseState extends State<InProgress> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 35),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    tooltip: "Back to home screen",
                    onPressed: !exerciseStarted ? backArrow: null,
                  ),
                  Text(
                      pushedExercise
                  )
                ]
              )
            ),
            Padding(
              padding: const EdgeInsets.only(),
              child: Row(
                children: <Widget>[
                  Icon(
                      Icons.accessibility_new,
                      size: 400,
                    ),
                ],
              ),
           ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            exerciseStarted = true;
                          });
                          if(blue._device != null){
                            blue.sendData([79,110]);
                          }
                          else{
                            showAlertDialog(context, "Device Error", "Please connect an exoskeleton device before attempting to start an exercise!");
                          }
                        },
                        child: Text("Start"),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      FlatButton(
                        onPressed: exerciseStarted ? stopButton: null,
                        child: Text("Stop"),
                      )
                    ],
                  )
                ],
              )
            )
          ]
        ),
      )
    );
  }

  void stopButton () {
    if (exerciseComplete == false) {
      Navigator.pushNamed(context, '/EndEarly');
    }
    else {
      blue.sendData([79,102,102]);
      Navigator.pop(context);
      exerciseComplete = false;
    }
  }

  void backArrow () {
   Navigator.pop(context);
}

}

//exercise end early screen state definer
class ExerciseEndState extends State<EndEarly> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(),
              child: Row(
                children: <Widget>[
                  Text(
                    "You are about to end the exercise early. End?"
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          blue.sendData([79,102,102]);
                          Navigator.pushNamed(context, '/');
                          setState(() {
                            exerciseStarted = false;
                          });
                        },
                        child: Text(
                          "Yes"
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "No"
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        )
    );
  }
}

//exercise metrics state definer
class MetricsState extends State<Metrics> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10, top: 35),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    tooltip: "Back to home screen",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Exercise Metrics"
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.insert_chart,
                    size: 400,
                  )
                ],
              ),
            )
          ],
        ),
    );
  }
}

class BluetoothState extends State<Bluetooth> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10,top: 35),
            child: Row(
              children: <Widget>[
                Text(
                  'Bluetooth Connection Settings'
                )
              ],
            ),
          ),
          Container(//second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
            height: SizeConfig.blockSizeVertical*14,
            width: SizeConfig.blockSizeHorizontal*94,
            child: FlatButton( //using the flat button class, simple interactive text based buttons
                textColor: Color.fromRGBO(0,40,85, 1.0),
                color: Color.fromRGBO(234, 170, 0, 1.0),
                child: Text( //defining the text within the button
                  'Connect To Arduino',
                  style: TextStyle(fontSize: 32),
                ),
                onPressed: () => blue.deviceScan(),
            ),
          )
        ],
      ),
    );
  }
}

showAlertDialog(BuildContext context, String title, String message) {

  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () { },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}