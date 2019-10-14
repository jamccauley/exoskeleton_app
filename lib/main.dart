import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:exoskeleton_app/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

//main boot screen
void main() {
  runApp(MaterialApp(
    title: "Exoskeleton Application",
    initialRoute: '/',
    routes: {
      '/': (context) => Homepage(),
      '/InProgress': (context) => InProgress(),
      '/EndEarly': (context) => EndEarly(),
      '/Bluetooth': (context) => FlutterBlueApp(),
      '/Metrics': (context) => Metrics()
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

//HomeState state definer
class HomeState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
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
                onTap: () {},
              ),
              ListTile(
                title: Text("Connect Device Via Bluetooth"),
                onTap: () async {
                  Navigator.pushNamed(context, '/Bluetooth');


                },
              ),
              ListTile(
                title: Text("View Exercise Metrics"),
                onTap: () async{
                  FlutterBlue flutterBlue = FlutterBlue.instance;
                  BluetoothDevice dev ;

                  flutterBlue
                      .scan(
                    scanMode: ScanMode.lowLatency,
                    timeout: const Duration(seconds: 12),
                  )
                      .listen((scanResult) {
                    BluetoothDevice device = scanResult.device;
                    if (scanResult.device.name == "BlunoMega") {
                      scanResult.device.connect();
                      dev = scanResult.device;
                      print('${device.name} found! rssi: ${scanResult.rssi}');
                    }
                  });


                 
                  Navigator.pushNamed(context, '/Metrics');
                },
              )
            ],
          ),
        ),
        backgroundColor: Colors.blue,
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
                      //second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
                      FlatButton(
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
    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Row(children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    tooltip: "Back to home screen",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(pushedExercise),
                ])),
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
                            setState(() {
                              exerciseStarted = true;
                            });
                          },
                          child: Text(
                            "Start",
                            style: TextStyle(color: Colors.white, fontSize: 25),
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
                ))
          ]),
        ));
  }

  void stopButton() {
    if (exerciseComplete == false) {
      Navigator.pushNamed(context, '/EndEarly');
    } else {
      Navigator.pop(context);
      exerciseComplete = false;
    }
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
                child: FlatButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                    setState(() {
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
              Padding(
                padding: EdgeInsets.all(10.0),
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
            ],
          ),
        ],
      ),
    );
  }
}

class MetricsState extends State<Metrics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: "Back to home screen",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text("Exercise Metrics")
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
          ),
          Divider(
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Start of bluetooth code

// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
Future<void> _restoreDeviceId(String id) async{
  final SharedPreferences prefs = await _prefs;
  String id = device.id.toString();
  prefs.setString("my device", id);
}*/
class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString()}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return RaisedButton(
                                    child: Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceScreen(device: d))),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            r.device.connect();

                            return DeviceScreen(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () => c.read(),
                    onWritePressed: () => c.write([13, 24]),
                    onNotificationPressed: () =>
                        c.setNotifyValue(!c.isNotifying),
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write([11, 12]),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              //Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';

                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        .copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
