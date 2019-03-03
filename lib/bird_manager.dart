import 'package:flutter/material.dart';

class BirdManager extends StatelessWidget {
  final List<Map<String, dynamic>> birds;

  BirdManager(this.birds);
  @override
  Widget build(BuildContext context) {
    print('[BirdManager State] build()');
    return Column(
      children: [
        // Container(height: 300.0, child: Birds(_birds)) // list view height
      ],
    );
  }
}
