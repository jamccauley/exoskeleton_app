

import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Homepage()
));

class Homepage extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //menu bar for the app, holds the nav drawer and can also contain text and all that
        elevation: 0,//elevation zero to eliminate the tacky drop shadow...
      ),
      drawer: Drawer(//navigation drawer, its the hamburger widget
        child: ListView(//define a list within the nav drawer
          children: <Widget>[
            UserAccountsDrawerHeader(//user account drawer; header pre-formatted
              accountName: Text("Sample User"),
              accountEmail: Text("sampleuser@mix.wvu.edu"),
              currentAccountPicture: CircleAvatar(//define the user avatar shape
                backgroundColor: Colors.grey,
                child: Text(//text inside the user avatar
                  "U",
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            ListTile(//list item, has interactivity and everything else
              title: Text("View Exercises"),
              onTap: () {},
            ),
            ListTile(
              title: Text("View Exercise Metrics"),
              onTap: () {},
           )
          ],
        ),
      ),
      backgroundColor: Colors.blue,
      body: SingleChildScrollView( //define the scrollview, may need to switch to a list view at some point to enable reloading of new exercises
        child: Column( //define the main column
          children: <Widget>[ //not sure why this widget is here, maybe to make all children of the scroll view interactive??
            Padding( //padding for second row
              padding: const EdgeInsets.all(12), //using .all ...
              child: Row( //second row
                children: <Widget>[ //second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
                  FlatButton( //using the flat button class, simple interactive text based buttons
                    textColor: Colors.blue,
                    color: Colors.white,
                    padding: EdgeInsets.all(12),
                    child: Text( //defining the text within the button
                      "Exercise 1",
                      style: TextStyle(fontSize: 32),
                    ),
                    onPressed: () {}, //onpressed for the exercise selection
                  )
                ],
              )
            ),
            Padding( //padding for second row
              padding: const EdgeInsets.all(12), //using .all ...
                child: Row( //third row
                  children: <Widget>[ //second (& third & fourth, ad nauseam) item will be exercise selection buttons, not sure if these are static or if we can update the list at will
                    FlatButton( //using the flat button class, simple interactive text based buttons
                      textColor: Colors.blue,
                      color: Colors.white,
                      padding: EdgeInsets.all(12),

                      child: Text( //defining the text within the button
                        "Exercise 2",
                        style: TextStyle(fontSize: 32),
                      ),
                      onPressed: () {}, //onpressed for the exercise selection
                    )
                  ],
                )
            )
          ],
        )
      )
    );
  }
}


