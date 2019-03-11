import 'package:flutter/material.dart';
import 'package:udemy_project/models/location_data.dart';

class Bird {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String imagePath;
  final LocationData location;
  final bool isFavorite;
  final String userMail;
  final String userId;
  Bird(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.image,
      @required this.price,
      @required this.location,
      this.isFavorite = false,
      @required this.imagePath,
      @required this.userMail,
      @required this.userId});
}
