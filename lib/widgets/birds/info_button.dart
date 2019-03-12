import 'package:flutter/material.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class InfoButton extends StatelessWidget {
  final String birdId;
  InfoButton(this.birdId);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return IconButton(
          icon: Icon(Icons.info),
          iconSize: 50.0,
          color: Colors.blue.shade300,
          onPressed: () {
            model.selectBird(birdId);
            Navigator.pushNamed<bool>(
              // after pushed page pops, then works. push and pops can send data.
              context,
              '/bird/' + birdId,
            ).then((_){
              model.selectBird(null);
            });
          },
        );
      },
    );
  }
}
