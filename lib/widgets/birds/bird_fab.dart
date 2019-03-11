import 'package:flutter/material.dart';

import 'package:udemy_project/models/bird.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as Math;

class BirdFab extends StatefulWidget {
  final Bird bird;
  BirdFab(this.bird);
  @override
  State<StatefulWidget> createState() {
    return _BirdFabState();
  }
}

class _BirdFabState extends State<BirdFab> with TickerProviderStateMixin {
  AnimationController _animationController;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: ScaleTransition(
                scale: CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(0.0, 1.0, curve: Curves.bounceInOut)),
                child: FloatingActionButton(
                  backgroundColor: Colors.greenAccent.shade100,
                  heroTag: 'contact',
                  mini: true,
                  onPressed: () async {
                    final url = 'mailto:${widget.bird.userMail}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch';
                    }
                  },
                  child: Icon(
                    Icons.message,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: ScaleTransition(
                scale: CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(0.0, 0.5, curve: Curves.bounceInOut)),
                child: FloatingActionButton(
                  backgroundColor: Colors.red.shade100,
                  heroTag: 'favorite',
                  mini: true,
                  onPressed: () {
                    model.toggleFavorite();
                  },
                  child: Icon(
                    model.selectedBird.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Container(
              height: 70.0,
              width: 56.0,
              child: FloatingActionButton(
                backgroundColor: Colors.black45,
                heroTag: 'options',
                mini: true,
                onPressed: () {
                  if (_animationController.isDismissed) {
                    _animationController.forward(); // play animation
                  } else {
                    _animationController.reverse(); // reverse animation
                  }
                },
                child: AnimatedBuilder(
                    animation:
                        _animationController, // when controller starts, this rebuilds itself.
                    builder: (BuildContext context, Widget child) {
                      return Transform(
                        alignment: FractionalOffset.center,
                        transform: Matrix4.rotationZ(
                            _animationController.value * 0.5 * Math.pi),
                        child: Icon(_animationController.isDismissed?
                          Icons.more_vert:Icons.close,
                          color: Colors.white70,
                        ),
                      );
                    }),
              ),
            ),
          ],
        );
      },
    );
  }
}
