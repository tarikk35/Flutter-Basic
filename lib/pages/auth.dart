import 'package:flutter/material.dart';

import 'package:udemy_project/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:udemy_project/models/auth.dart';

import 'package:udemy_project/widgets/ui_elements/adaptive_progress_indicator.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'accept_terms': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pwTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  AnimationController _animationController;
  Animation<Offset> _slideAnimation;

  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, -2.0), end: Offset.zero).animate( // -2.0 means twice the object's height.
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    super.initState();
  }

  Widget _buildIDText() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.perm_identity),
        labelText: 'ID',
        filled: true,
        fillColor: Colors.white70,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPWText() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline),
        labelText: 'PW',
        filled: true,
        fillColor: Colors.white70,
      ),
      controller: _pwTextController, // accessing a widget's properties
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password should be at least 6 characters long';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPWConfirmText() {
    return FadeTransition(
      opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.0, 1.0, curve: Curves.easeIn)),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            labelText: 'Confirm Password',
            filled: true,
            fillColor: Colors.white70,
          ),
          obscureText: true,
          validator: (String value) {
            if (_pwTextController.text != value &&
                _authMode == AuthMode.Signup) {
              return 'Passwords do not match';
            }
          },
        ),
      ),
    );
  }

  Widget _buildSwitch() {
    return SwitchListTile(
      value: _formData['accept_terms'],
      onChanged: (bool value) {
        setState(() {
          _formData['accept_terms'] = !_formData['accept_terms'];
        });
      },
      title: Text('Accept Terms'),
    );
  }

  void _validate(Function authenticate) async {
    if (!_formKey.currentState.validate() || !_formData['accept_terms']) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInfo = await authenticate(
        _formData['email'], _formData['password'], _authMode);

    if (successInfo['success']) {
      // Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An error Occured'),
            content: Text(successInfo['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.9;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), BlendMode.dstATop),
            image: AssetImage('assets/bgbird.jpg'),
          ),
        ),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildIDText(),
                    SizedBox(
                      height: 20.0,
                    ),
                    _buildPWText(),
                    SizedBox(height: 20.0),
                    _buildPWConfirmText(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildSwitch(),
                    SizedBox(
                      height: 20.0,
                    ),
                    FlatButton(
                      child: Text(
                          'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                      onPressed: () {
                        if (_authMode == AuthMode.Login) {
                          setState(() {
                            _authMode = AuthMode.Signup;
                          });
                          _animationController.forward();
                        } else {
                          setState(() {
                            _authMode = AuthMode.Login;
                          });
                          _animationController.reverse();
                        }
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    ScopedModelDescendant<MainModel>(
                      builder: (BuildContext context, Widget child,
                          MainModel model) {
                        return model.isLoading
                            ? AdaptiveProgressIndicator()
                            : RaisedButton(
                                child: Text(_authMode == AuthMode.Login
                                    ? 'Login'
                                    : 'Sign Up'),
                                onPressed: () {
                                  _validate(model.authenticate);
                                },
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
