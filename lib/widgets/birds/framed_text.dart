import 'package:flutter/material.dart';

class FramedText extends StatelessWidget {
  final String text;
  FramedText(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
            style: BorderStyle.solid, color: Colors.grey, width: 1.4),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Text('Turkey'),
      ),
    );
  }
}
