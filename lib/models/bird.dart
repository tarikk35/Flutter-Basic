import 'package:flutter/material.dart';

class Bird {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String address;
  final bool isFavorite;
  final String userMail;
  final String userId;
  Bird(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.image,
      @required this.price,
      @required this.address,
      this.isFavorite = false,
      @required this.userMail,
      @required this.userId});
}
