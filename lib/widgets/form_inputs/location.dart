import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:udemy_project/widgets/helpers/ensure-visible.dart';
import 'package:udemy_project/models/location_data.dart';
import 'package:udemy_project/models/bird.dart';
import 'package:location/location.dart' as geoloc;

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Bird bird;
  LocationInput(this.setLocation, this.bird);
  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  Uri _staticMapUri;
  final FocusNode _addressInputFocusNode = FocusNode();
  LocationData _locationData=LocationData();
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.bird != null) {
      getStaticMap(widget.bird.location.address, geoCode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void getStaticMap(String address,
      {bool geoCode: true, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geoCode) {
      final http.Response response = await http.get(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=AIzaSyBW7UZdXf38hmqQYyBxJIIchKbqAZ8ryfY');
      final decodedResponse = json.decode(response.body);
      final formattedAddress =
          decodedResponse['results'][0]['formatted_address'];
      final coords = decodedResponse['results'][0]['geometry']['location'];

      _locationData = LocationData(
          address: formattedAddress,
          latitude: coords['lat'],
          longitude: coords['lng']);
    } else if (lat == null && lng == null) {
      _locationData = widget.bird.location;
    } else {
      _locationData =
          LocationData(address: address, latitude: lat, longitude: lng);
    }
    if (mounted) { // prevents the error when the widget is not alive but still tries to call a method.
      final StaticMapProvider staticMapViewProvider =
          StaticMapProvider('AIzaSyBW7UZdXf38hmqQYyBxJIIchKbqAZ8ryfY');
      final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers([
        Marker('position', 'Position', _locationData.latitude,
            _locationData.longitude)
      ],
          center: Location(_locationData.latitude, _locationData.longitude),
          width: 500,
          height: 300,
          maptype: StaticMapViewType.roadmap);
      widget.setLocation(_locationData);
      setState(() {
        _addressInputController.text = _locationData.address;
        _staticMapUri = staticMapUri;
      });
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    final http.Response response = await http.get(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat.toString()},${lng.toString()}&key=AIzaSyBW7UZdXf38hmqQYyBxJIIchKbqAZ8ryfY');
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  void _getUserLocation() async {
    final geoloc.Location location = geoloc.Location();
    final currentLocation = await location.getLocation();
    final address = await _getAddress(
        currentLocation['latitude'], currentLocation['longitude']);
    getStaticMap(address,
        geoCode: false,
        lat: currentLocation['latitude'],
        lng: currentLocation['longitude']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            decoration: InputDecoration(labelText: 'Address'),
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found';
              }
            },
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        IconButton(
          icon: Icon(Icons.my_location),
          onPressed: _getUserLocation,
          iconSize: 40.0,
        ),
        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString())
      ],
    );
  }
}
