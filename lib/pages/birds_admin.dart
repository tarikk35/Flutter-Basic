import 'package:flutter/material.dart';

import './bird_edit.dart';
import 'bird_list.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:udemy_project/widgets/ui_elements/logout_list_tile.dart';

class BirdsAdminPage extends StatelessWidget {
  final MainModel model;
  BirdsAdminPage(this.model);
  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            title: Text('Admin CCC'),
          ),
          ListTile(
            leading: Icon(Icons.keyboard_return),
            title: Text('Return to Homepage'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildAdminDrawer(context),
        appBar: AppBar(
          title: Text('Manage Birds'),
          elevation: 0.0,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Bird',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Birds',
              ),
            ],
          ),
        ),
        body: TabBarView(
          // this tabs dont replace the main page.
          children: <Widget>[
            BirdEditPage(),
            BirdListPage(model),
          ],
        ),
      ),
    );
  }
}
