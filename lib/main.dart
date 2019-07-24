

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
      backgroundColor: Colors.blue,
      body: SingleChildScrollView( //define the scrollview, may need to switch to a list view at some point to enable reloading of new exercises
        child: Column( //define the main column
          children: <Widget>[ //not sure why this widget is here, maybe to make all children of the scroll view interactive??
            Padding( //padding to offset edges of buttons
                padding: const EdgeInsets.only( //define padding, .only gives full control of all directions, .all sets all pads the same
                  left: 12, right: 12, top: 30,bottom: 8),
                child: Row( //first row in the scroll view
                  children: <Widget>[ //first item in the row is a widget (menu button)
                    IconButton( //defining the button using the icon button class
                      icon: Icon(
                        IconData(58834, fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                        size: 60,
                      ),
                    onPressed: () {}, //on pressed method for raising the menu
                  )
                ],
              )
            ),
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
            )
          ],
        )
      )
    );
  }
}

