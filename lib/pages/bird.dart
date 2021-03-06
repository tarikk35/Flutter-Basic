import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/ui_elements/title.dart';
import '../widgets/birds/price_tag.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:udemy_project/models/bird.dart';
import 'package:map_view/map_view.dart';
import 'package:udemy_project/widgets/birds/bird_fab.dart';

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

  void _showMap() {
    final List<Marker> markers = <Marker>[
      Marker('position', 'Position', bird.location.latitude,
          bird.location.longitude),
    ];
    final camPosition = CameraPosition(
        Location(bird.location.latitude, bird.location.longitude), 15.0);
    final mapView = MapView();
    mapView.show(
        MapOptions(
            mapViewType: MapViewType.normal,
            title: 'Bird Location',
            initialCameraPosition: camPosition),
        toolbarActions: [ToolbarAction('Close', 1)]);
    mapView.onToolbarAction.listen((int id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
    mapView.onMapReady.listen((_) {
      mapView.setMarkers(markers);
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
        // appBar: AppBar(
        //   title: Text(bird.title),
        // ),
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            elevation: 0.0,
            expandedHeight: 256.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(bird.title),
              background: Hero(
                tag: bird.id,
                child: FadeInImage(
                  // image placeholder while data is downloading.
                  image: NetworkImage(bird.image),
                  height: 300.0,
                  fit: BoxFit
                      .cover, // doesnt destroy image. uses a part of image.
                  fadeInCurve: Curves
                      .fastOutSlowIn, // fade animation when new image is loaded.
                  placeholder: AssetImage('assets/bgbird.jpg'),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
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
                Text(
                  bird.description,
                  style: TextStyle(fontSize: 20.0),
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(top: 20.0, left: 20.0),
                    alignment: FractionalOffset.center,
                    child: Row(
                      children: <Widget>[
                        Text(
                          bird.location.address,
                          style: TextStyle(fontSize: 30.0),
                        ),
                        Icon(Icons.location_on),
                      ],
                    ),
                  ),
                  onTap: _showMap,
                ),
                IconButton(
                    color: Theme.of(context).primaryColor,
                    icon: Icon(Icons.delete),
                    iconSize: 60.0,
                    onPressed: () => _showWarningDialog(context)),
              ],
            ),
          ),
        ]),
        floatingActionButton: BirdFab(
            bird), // floatingActionButton's basic location is bottom right.
      ),
    );
  }
}
