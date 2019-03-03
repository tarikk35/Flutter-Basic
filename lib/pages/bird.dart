import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/ui_elements/title.dart';
import '../widgets/birds/price_tag.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:udemy_project/models/bird.dart';

class BirdPage extends StatelessWidget {
  final Bird bird;
  BirdPage(this.bird);
  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return AlertDialog(
                title: Text('Are you sure?'),
                content: Text('You are about to delete a bird :('),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.cancel),
                    iconSize: 50.0,
                    color: Colors.redAccent.shade200,
                    onPressed: () {
                      Navigator.pop(context); //closes the dialog
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever),
                    iconSize: 50.0,
                    color: Colors.grey,
                    onPressed: () {
                      model.selectBird(bird.id);
                      model.deleteBird();
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                  )
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Back button pressed !');
        Navigator.pop(context, false);
        return Future.value(false); // only execute custom pop.
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(bird.title),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FadeInImage(
              // image placeholder while data is downloading.
              image: NetworkImage(bird.image),
              height: 300.0,
              fit: BoxFit.cover, // doesnt destroy image. uses a part of image.
              fadeInCurve: Curves
                  .fastOutSlowIn, // fade animation when new image is loaded.
              placeholder: AssetImage('assets/bgbird.jpg'),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TitleDefault(bird.title),
                PriceTag(bird.price.toString()),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  bird.description,
                  style: TextStyle(fontSize: 20.0),
                ),
                Text(
                  bird.address,
                  style: TextStyle(fontSize: 20.0),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                    color: Theme.of(context).primaryColor,
                    icon: Icon(Icons.delete),
                    iconSize: 60.0,
                    onPressed: () => _showWarningDialog(context))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
