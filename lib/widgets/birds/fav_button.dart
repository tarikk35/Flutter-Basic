import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:udemy_project/models/bird.dart';

class FavButton extends StatelessWidget {
  final Bird bird;
  FavButton(this.bird);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return IconButton(
          icon: bird.isFavorite
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border),
          iconSize: 50.0,
          color: Colors.redAccent.shade200,
          onPressed: () {
            // model.selectBird(bird.id);
            model.toggleFavorite(bird);
          },
        );
      },
    );
  }
}
