import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './bird_card.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:udemy_project/models/bird.dart';

class Birds extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BirdsState();
  }
}

class _BirdsState extends State<Birds> {
  Widget birdCards(List<Bird> birdList) {
    if (birdList.length > 0) {
      return ListView.builder(
        // builder is optimized. items are not rendered when not seen
        itemBuilder: (BuildContext context, int index) => BirdCard(
            birdList[index],
            index), // function without parantheses only takes the ref and uses when needed
        itemCount: birdList.length,
      );
    } else {
      return Center(child: Text('No Birds Found!'));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[Birds Widget] build()');
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return birdCards(model.displayedBirds);
      },
    );
  }
}
