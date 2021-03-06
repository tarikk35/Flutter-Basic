import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../widgets/helpers/ensure-visible.dart';
import 'package:udemy_project/models/bird.dart';
import 'package:udemy_project/scoped_models/main.dart';
import 'package:udemy_project/widgets/form_inputs/location.dart';
import 'package:udemy_project/models/location_data.dart';
import 'package:udemy_project/widgets/form_inputs/image.dart';
import 'dart:io';
import 'package:udemy_project/widgets/ui_elements/adaptive_progress_indicator.dart';

class BirdEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BirdEditPageState();
  }
}

class _BirdEditPageState extends State<BirdEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null,
    'location': LocationData()
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();

  void _submitBird(
      Function addBird, Function editBird, Function setSelectedBird,
      [int selectedBirdIndex]) {
    if (!_formKey.currentState.validate() ||
        (_formData['image'] == null) && selectedBirdIndex == -1) {
      // if image is not picked and not in edit mode
      return;
    }
    _formKey.currentState.save();
    if (selectedBirdIndex == -1) {
      addBird(
        _formData['title'],
        _formData['description'],
        _formData['image'],
        double.parse(_formData['price'].toString().replaceFirst(RegExp(r','), '.')),
        _formData['location'],
      ).then((bool success) {
        {
          if (success) {
            Navigator.pushReplacementNamed(context, '/mainpage')
                .then((_) => setSelectedBird());
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong.'),
                  content: Text('Please try again.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                );
              },
            );
          }
        }
      });
    } else {
      editBird(
        _formData['title'],
        _formData['description'],
        _formData['image'],
        double.parse(_formData['price'].toString().replaceFirst(RegExp(r','), '.')),
        _formData['location'],
      ).then((_) => Navigator.pushReplacementNamed(context, '/mainpage')
          .then((_) => setSelectedBird()));
    }
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  Widget _saveBirdButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(
              child: AdaptiveProgressIndicator()) 
          : IconButton(
              icon: Icon(Icons.save),
              iconSize: 80.0,
              color: Theme.of(context).accentColor,
              onPressed: () => _submitBird(model.addBird, model.editBird,
                  model.selectBird, model.selectedBirdIndex),
            );
    });
  }

  Widget _buildBirdNameText(Bird bird) {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        initialValue: bird == null ? '' : bird.title,
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return 'Title should be at least 5 characters long';
          }
        },
        decoration: InputDecoration(
          labelText: 'Bird Name',
        ),
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildBirdDescText(Bird bird) {
    return EnsureVisibleWhenFocused(
      focusNode: _descFocusNode,
      child: TextFormField(
          focusNode: _descFocusNode,
          initialValue: bird == null ? '' : bird.description,
          validator: (String value) {
            if (value.isEmpty || value.length < 10) {
              return 'Description should be at least 10 characters long';
            }
          },
          decoration: InputDecoration(labelText: 'Bird Description'),
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          onSaved: (String value) {
            _formData['description'] = value;
          }),
    );
  }

  Widget _buildBirdPriceText(Bird bird) {
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
          focusNode: _priceFocusNode,
          initialValue: bird == null ? '' : bird.price.toString(),
          validator: (String value) {
            if (value.isEmpty ||
                !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
              return 'Invalid price';
            }
          },
          decoration: InputDecoration(labelText: 'Bird Price (\$)'),
          keyboardType: TextInputType.number,
          onSaved: (String value) {
            _formData['price'] = value;
          }),
    );
  }

  void _setLocation(LocationData locData) {
    _formData['location'] = locData;
  }

  Widget _buildPageContent(BuildContext context, Bird bird) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.95;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: (deviceWidth - targetWidth) / 2),
            child: Column(
              children: <Widget>[
                _buildBirdNameText(bird),
                _buildBirdDescText(bird),
                _buildBirdPriceText(bird),
                SizedBox(
                  height: 10.0,
                ),
                LocationInput(_setLocation, bird),
                SizedBox(
                  height: 10.0,
                ),
                ImageInput(_setImage, bird),
                SizedBox(
                  height: 10.0,
                ),
                _saveBirdButton(),
                // GestureDetector(
                //   child: Container(
                //     color: Colors.green,
                //     padding: EdgeInsets.all(10.0),
                //     child: Text('My Secret Text'),
                //   ),
                //   // onLongPress: _createBird,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final Widget pageContent = _buildPageContent(context, model.selectedBird);
      return model.selectedBirdIndex == -1 // integer return -1 as null value
          ? pageContent
          : Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                title: Text('Edit Birds'),
              ),
              body: pageContent,
            );
    });
  }
}
