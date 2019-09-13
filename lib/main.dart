import 'package:flutter/material.dart';

//declarations
String exercise;
String pushedExercise;
bool exerciseStarted = false;
bool exerciseComplete = false;
List<String> dbList = ["Elbow Abduction", "Elbow Adduction", "Shoulder Abduction", "Shoulder Adduction", "Elbow Abduction 2"];

//main boot screen
void main() {
runApp(MaterialApp(
  title: "Exoskeleton Application",
  initialRoute: '/',
  routes: {
    '/': (context) => Homepage(),
    '/InProgress': (context) => InProgress(),
    '/EndEarly': (context) => EndEarly(),
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

//HomeState state definer
class HomeState extends State<Homepage> {

  @override
  Widget build(BuildContext context) {
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
                            children: <Widget>[ //second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
                              FlatButton( //using the flat button class, simple interactive text based buttons
                                textColor: Color.fromRGBO(0,40,85, 1.0),
                                color: Color.fromRGBO(234, 170, 0, 1.0),
                                padding: EdgeInsets.fromLTRB(10,10,10,10),
                                child: Text( //defining the text within the button
                                  dbList[i],
                                  style: TextStyle(fontSize: 32),
                                ),
                                onPressed: () => onExerButtonPressed(dbList[i])//onpressed for the exercise selection
                              ),
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
              padding: const EdgeInsets.only(left: 10, top: 10),
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

