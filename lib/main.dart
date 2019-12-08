import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;

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
List<String> dbList = [
  "Elbow Abduction",
  "Elbow Adduction",
  "Shoulder Abduction",
  "Shoulder Adduction",
  "Elbow Abduction 2"
];
BluetoothDevice passedDevice;
BluetoothSetup blue = new BluetoothSetup();
List<int> receivedFlexValues = [];
int repCounter = 0;
List<FlexData> flexData = [];
int i = 0;
bool lastMessage = false;

class BluetoothSetup {
  FlutterBlue bluetooth = FlutterBlue.instance;
  StreamSubscription scanSubscription;
  BluetoothDevice _device;
  List<BluetoothService> services;
  bool deviceConnected = false;
  var message;
  BluetoothCharacteristic serialPort;

  deviceScan() async{
    scanSubscription = null;
    scanSubscription = bluetooth.scan().listen((scanResult) {
      _device = scanResult.device;
      print(_device.name);

      if (_device.name == 'BlunoMega'){
        connect(_device);
      }
    });
  }

  connect(BluetoothDevice _device) async{
    blue.scanSubscription.cancel();

    await _device.connect();

    passedDevice = _device;
    deviceConnected = true;

    findServices();
  }

  deviceDisconnect(_device) {
    _device.disconnect();
  }

  stopScan() {
    scanSubscription.cancel();
  }

  findServices() async {
    services = await _device.discoverServices();
    services.forEach((service){
      //print(service.uuid);
    });
    List<BluetoothCharacteristic> c = services[3].characteristics;
    List<BluetoothDescriptor> d = c[0].descriptors;

    d.forEach((descriptor){
      print(descriptor.uuid);
    });

    return services;
  }

  sendData(List<int> data,BuildContext context) async{
    List<BluetoothCharacteristic> c = services[3].characteristics;

    serialPort = c[0];

    await serialPort.write(data);

    await serialPort.setNotifyValue(true);

    serialPort.value.listen((value) {
        //print(value);
      if(repCounter <= 4) {
        List<int> serialData = value;
        serialHandler(serialData);
      }
      else{
        exerciseComplete = true;
        exerciseStarted = false;
        endListen();
        repCounter = 0;
        i = 0;
        Navigator.pushNamed(context, '/Metrics');
      }
    });
  }

  List<int> getReceivedData() {
    return message;
  }

  endListen() async {
    await serialPort.setNotifyValue(false);
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

//end early warning screen
class EndEarly extends StatefulWidget {
  @override
  ExerciseEndState createState() => new ExerciseEndState();
}

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
        appBar: AppBar(
          //menu bar for the app, holds the nav drawer and can also contain text and all that
          elevation: 0, //elevation zero to eliminate the tacky drop shadow...
        ),
        drawer: Drawer(
          //navigation drawer, its the hamburger widget
          child: ListView(
            //define a list within the nav drawer
            children: <Widget>[
              UserAccountsDrawerHeader(
                //user account drawer; header pre-formatted
                accountName: Text("Sample User"),
                accountEmail: Text("sampleuser@mix.wvu.edu"),
                currentAccountPicture: CircleAvatar(
                  //define the user avatar shape
                  backgroundColor: Colors.grey,
                  child: Text(
                    //text inside the user avatar
                    "U",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
              ListTile(
                //list item, has interactivity and everything else
                title: Text("View Exercises"),
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              ),

              ListTile(
                title: Text("View Exercise Metrics"),
                onTap: () async {
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
        backgroundColor: Colors.lightBlueAccent,
        //body: RefreshIndicator(
        //onRefresh: E.refresh(),
        body: SingleChildScrollView(
            //define the scrollview, may need to switch to a list view at some point to enable reloading of new exercises
            child: Column(
          //define the main column
          children: <Widget>[
            //not sure why this widget is here, maybe to make all children of the scroll view interactive??
            for (var i = 0; i < dbList.length; i++) //using .all ...
              Padding(
                  //padding for second row
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    //second row
                    children: <Widget>[
                      Container(//second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
                        height: SizeConfig.blockSizeVertical*14,
                        width: SizeConfig.blockSizeHorizontal*94,
                      //second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
                        child: FlatButton(
                          //using the flat button class, simple interactive text based buttons
                          textColor: Colors.blue,
                          color: Colors.white,
                          padding: EdgeInsets.all(12),
                          child: Text(
                            //defining the text within the button
                            dbList[i],
                            style: TextStyle(fontSize: 32),
                          ),
                          onPressed: () => onExerButtonPressed(
                              dbList[i]) //onpressed for the exercise selection
                          ),
                      )
                    ],
                  )),
          ],
        ))
        //  )
        );
  }

  void onExerButtonPressed(String selectedExercise) {
    pushedExercise = selectedExercise;
    Navigator.pushNamed(context, '/InProgress');
  }
}

//Exercise in progress state definer
class ExerciseState extends State<InProgress> {
  @override
  Widget build(BuildContext context) {
    repCounter = 0;
    i = 0;

    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(left: 10, top: 40),
                child: Row(
                    children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    tooltip: "Back to home screen",
                    onPressed: !exerciseStarted ? backArrow: null,
                    color: Colors.white,
                    iconSize: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                  child: Text(
                      pushedExercise,
                      style: TextStyle(fontSize: 30,color: Colors.white)
                  )
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
                    color: Colors.yellow,
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.white,
            ),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            if(blue._device != null){
                              setState(() {
                                exerciseStarted = true;
                              });
                              if(pushedExercise.contains("Elbow")) {
                                blue.sendData([101, 108, 98],context);
                              }
                              else{
                                blue.sendData([115,104,111],context);
                              }
                            }
                            else{
                              showAlertDialog(context, "Device Error", "Please connect an exoskeleton device before attempting to start an exercise!");
                            }
                          },
                          child: Text("Start", style: TextStyle(color: Colors.white, fontSize: 25),

                        ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          onPressed: exerciseStarted ? stopButton : null,
                          child: Text(
                            "Stop",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        )
                      ],
                    )
                  ],
                )),
            Divider(
              color: Colors.white,
            ),
          ]),
        ));
  }

  void stopButton() {
    if (exerciseComplete == false) {
      Navigator.pushNamed(context, '/EndEarly');
    } else {
      //blue.sendData([115,116,111,112]);
      Navigator.pop(context);
      exerciseComplete = false;
    }
  }
  void backArrow () {
    Navigator.pop(context);
  }
}

class ExerciseEndState extends State<EndEarly> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "You are about to end the exercise early. End?",
                    style: TextStyle(fontSize: 40, color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  color: Colors.white,
                  child: FlatButton(
                    onPressed: () {
                      blue.sendData([115,116,111,112],context);
                      blue.endListen();
                      repCounter = 0;
                      i = 0;
                      Navigator.pushNamed(context, '/Metrics');
                      setState(() {
                        exerciseComplete = true;
                        exerciseStarted = false;
                      });
                    },
                    child: Text(
                      "Yes",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 35, color: Colors.greenAccent),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  color: Colors.white,
                  child: FlatButton(
                      onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "No",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 35, color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricsState extends State<Metrics> {

  @override
  static var data = flexData;

  static var series = [
    new charts.Series(
      domainFn: (FlexData chartData, _) => chartData.index,
      measureFn: (FlexData chartData, _) => chartData.flex,
      id: 'Flex Value',
      data: data,
    ),
  ];

  static var chart = new charts.LineChart(
    series,
    animate: false,
  );


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 12, top: 50),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: "Back to home screen",
                  onPressed: () {
                    Navigator.pushNamed(context,'/');
                    flexData = [];
                    receivedFlexValues = [];
                  },
                  color: Colors.white,
                  iconSize: 40,
                ),
                Text(
                  "Exercise Metrics",
                  style: TextStyle(fontSize: 28,color: Colors.white),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              height: 400.0,
              width: 400.0,
              child: chart,
            ),
          ),
          Divider(
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class BluetoothState extends State<Bluetooth> {

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10,top: 50),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: "Back to home screen",
                  onPressed: () {
                    backArrow();
                  },
                  color: Colors.white,
                ),
                Text(
                    'Bluetooth Connection Settings',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
          child: Container(//second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
            height: SizeConfig.blockSizeVertical*14,
            width: SizeConfig.blockSizeHorizontal*94,
            child: FlatButton( //using the flat button class, simple interactive text based buttons
              textColor: Colors.lightBlueAccent,
              color: Colors.white,
              child: Text( //defining the text within the button
                'Connect To Arduino',
                style: TextStyle(fontSize: 31),
              ),
              onPressed: () {
                blue.deviceScan();
                setState(() {
                  blue.deviceConnected;
                });
              }
            ),
          ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Container(//second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
              height: SizeConfig.blockSizeVertical*14,
              width: SizeConfig.blockSizeHorizontal*94,
              child: FlatButton( //using the flat button class, simple interactive text based buttons
                textColor: Colors.lightBlueAccent,
                color: Colors.white,
                child: Text( //defining the text within the button
                  'Disconnect From Arduino',
                  style: TextStyle(fontSize: 31),
                ),
                onPressed: () => blue.deviceDisconnect(blue._device)
              ),
            ),
          ),
        ],
      ),
    );
  }

  backArrow() {
    if(blue.scanSubscription != null){
      blue.stopScan();
    }
    Navigator.pop(context);
  }
}

showAlertDialog(BuildContext context, String title, String message) {

  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () { 
      Navigator.pop(context);
    },
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

serialHandler(List<int> serialData) {
  //parse and translate the incoming serial data
  var message = utf8.decode(serialData);

  //do something with each message
  //might need a switch case for each type of message
  //also need to decide which messages to send
  //possibly store and use as metrics later on?
  //send myoware sensor values to make a graph?
  print(message);

  if (message.contains("REP") && lastMessage != true) {
    repCounter++;
    lastMessage = true;
  }
  else{
    receivedFlexValues.add(serialData[0]);
    flexData.add(FlexData(i, receivedFlexValues[i]));
    i++;
    lastMessage = false;
  }
}

class FlexData {
  final int index;
  final int flex;

  FlexData(this.index, this.flex);
}