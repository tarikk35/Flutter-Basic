import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
// import 'package:flutter/rendering.dart';

import 'pages/birds_admin.dart';
import 'pages/birdspage.dart';
import 'pages/auth.dart';
import 'pages/bird.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'models/bird.dart';

void main() {
  // debugPaintSizeEnabled = true; // visual debugging.
//   debugPaintBaselinesEnabled = true;
//   debugPaintPointersEnabled = true;
  runApp(MyApp());
} // main function runs when app loaded

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final MainModel model=MainModel();
    // build method returns widget type.
    return ScopedModel<MainModel>(
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Caviar',
          primarySwatch: Colors.blueGrey,
          accentColor: Colors.deepOrange,
          backgroundColor: Colors.black,
          buttonColor: Colors.amber,
        ),
        routes: {
          '/': (BuildContext context) => AuthPage(), // '/' equals homepage.
          '/mainpage': (BuildContext context) => BirdsPage(model),
          '/admin': (BuildContext context) => BirdsAdminPage(model),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          print(pathElements[0]);
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'bird') {
            final String birdId = pathElements[2];
            final Bird bird=model.allBirds.firstWhere((Bird b){
              return b.id==birdId;
            });
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => BirdPage(bird));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => BirdsPage(model));
        },
        //home: AuthPage(),
      ),
      model: model,
    );
  }
}

// stateless widgets render UI, can take data into them and data can change externally
// gets re-rendered when input data changes
// stateless widgets built by build() constructor function

//stateful widgets can render UI, can take data into them
// gets re-rendered when input data or local state changes
// stateful widgets built by build() but can call initState() before
// building. setState() can be called after building/when some event happens.
// didUpdateWidget() when external data changes.

// order : createState > initState > didUpdateWidget > build
// Constructor > build
