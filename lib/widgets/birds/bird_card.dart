import 'package:flutter/material.dart';

import './price_tag.dart';
import './info_button.dart';
import './fav_button.dart';
import './framed_text.dart';
import '../ui_elements/title.dart';
import 'package:udemy_project/models/bird.dart';

class BirdCard extends StatelessWidget {
  final Bird bird;
  final int birdIndex;
  BirdCard(this.bird, this.birdIndex);

  @override
  Widget build(BuildContext context) {
    return Card(
      // card widget takes all width.
      child: Column(
        children: <Widget>[
          Hero(
            tag: bird.id,
            child: FadeInImage(
              // image placeholder while data is downloading.
              image: NetworkImage(bird.image),
              height: 300.0,
              fit: BoxFit.cover, // doesnt destroy image. uses a part of image.
              fadeInCurve: Curves
                  .fastOutSlowIn, // fade animation when new image is loaded.
              placeholder: AssetImage('assets/bgbird.jpg'),
            ),
          ),
          Padding(
            // SizedBox or Padding or Container
            padding: EdgeInsets.only(
                top:
                    20.0), // special margin . symmetric is also an option. padding is also an option
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: TitleDefault(bird.title),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Flexible(
                  child: PriceTag(bird.price.toString()),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          FramedText(bird.location.address),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              InfoButton(bird.id),
              FavButton(bird),
            ],
          )
        ],
      ),
    );
  }
}
