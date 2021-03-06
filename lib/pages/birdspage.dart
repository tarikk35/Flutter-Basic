import 'package:flutter/material.dart';

import '../widgets/birds/birds.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:udemy_project/widgets/ui_elements/logout_list_tile.dart';
import 'package:udemy_project/widgets/ui_elements/adaptive_progress_indicator.dart';

class BirdsPage extends StatefulWidget {
  final MainModel model;
  BirdsPage(this.model);
  @override
  State<StatefulWidget> createState() {
    return _BirdsPageState();
  }
}

class _BirdsPageState extends State<BirdsPage> {
  @override
  initState() {
    widget.model.fetchBirds();
    super.initState();
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Birds'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  Widget _buildBirdsList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = Center(
          child: Text('No birds found'),
        );
        if (model.displayedBirds.length > 0) {
          content = Birds();
        } else if (model.isLoading) {
          content = Center(
            child: AdaptiveProgressIndicator(),
          );
        }
        return RefreshIndicator(
            child: content,
            onRefresh: // pull down to refresh page
                model.fetchBirds);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Birb List'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.toggleDisplayMode();
                },
                color: Colors.redAccent.shade200,
                iconSize: 40.0,
              );
            },
          ),
        ],
      ),
      body: _buildBirdsList(),
    );
  }
}
