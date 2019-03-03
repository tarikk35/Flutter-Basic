import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:udemy_project/scoped_models/main.dart';

class FavButton extends StatelessWidget {
  final int birdIndex;
  FavButton(this.birdIndex);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return IconButton(
          icon: model.displayedBirds[birdIndex].isFavorite
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border),
          iconSize: 50.0,
          color: Colors.redAccent.shade200,
          onPressed: () {
            model.selectBird(model.allBirds[birdIndex].id);
            model.toggleFavorite();
          },
        );
      },
    );
  }
}
