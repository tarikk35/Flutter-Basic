import 'package:flutter/material.dart';
import './bird_edit.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:udemy_project/scoped_models/main.dart';

class BirdListPage extends StatefulWidget {
  final MainModel model;
  BirdListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _BirdListPageState();
  }
}

class _BirdListPageState extends State<BirdListPage> {
  @override
  initState() {
    widget.model.fetchBirds();
    super.initState();
  }

  Widget _buildEditIconButton(
      BuildContext context, int index, MainModel model) {
    return IconButton(
      iconSize: 40.0,
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectBird(model.allBirds[index].id);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) {
            return BirdEditPage();
          }),
        ).then((_) => model.selectBird(null));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.displayedBirds[index].title),
              background: Container(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white, fontSize: 30.0),
                ),
                color: Colors.redAccent.shade200,
              ),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectBird(model.allBirds[index].id);
                  model.deleteBird();
                } else if (direction == DismissDirection.startToEnd) {
                  print('swiped to end');
                } else {
                  print(direction);
                }
              },
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      maxRadius: 24.0,
                      backgroundImage:
                          NetworkImage(model.displayedBirds[index].image),
                    ),
                    title: Text(model.displayedBirds[index].title),
                    subtitle: Text('\$ ${model.displayedBirds[index].price}'),
                    trailing: _buildEditIconButton(context, index, model),
                  ),
                  Divider(color: Colors.black),
                ],
              ),
            );
          },
          itemCount: model.displayedBirds.length,
        );
      },
    );
  }
}
