import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udemy_project/models/bird.dart';
import 'package:udemy_project/models/user.dart';
import 'package:udemy_project/models/auth.dart';
import 'package:rxdart/subjects.dart';
import 'package:udemy_project/models/location_data.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

mixin ConnectedBirdsModel on Model {
  List<Bird> _birds = []; // My main list of Birds.
  User _authenticatedUser;
  String _selectedBirdId;
  bool _isLoading = false;
}

mixin BirdsModel on ConnectedBirdsModel {
  bool _showFavorites = false;

  List<Bird> get allBirds {
    return List.from(_birds);
  }

  List<Bird> get displayedBirds {
    // I dont want anyone to access my main list and change/edit it.
    if (_showFavorites) {
      // So I'm sending a copy by using List.from method
      return _birds.where((Bird bird) => bird.isFavorite).toList();
    }
    return List.from(_birds);
  }

  int get selectedBirdIndex {
    return _birds.indexWhere((Bird bird) {
      return bird.id == _selectedBirdId;
    });
  }

  String get selectedBirdId {
    return _selectedBirdId;
  }

  Future<bool> addBird(String title, String description, File image,
      double price, LocationData locData) async {
    _isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);
    if (uploadData == null) {
      print('Upload failed');
      return false;
    }
    // Only functions below can change main list of Birds.
    final Map<String, dynamic> birdData = {
      'title': title,
      'description': description,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
    };
    try {
      final http.Response response = await http.post(
          // await = wait process to finish.
          'https://flutter-birds.firebaseio.com/birds.json?auth=${_authenticatedUser.token}',
          body: json.encode(birdData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Bird bird = Bird(
          id: responseData['name'],
          location: locData,
          title: title,
          description: description,
          image: uploadData['imageUrl'],
          imagePath: uploadData['imagePath'],
          price: price,
          userMail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _birds.add(bird);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      // error catching
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-flutter-birds.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';
    try {
      final streamResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong ${json.decode(response.body)}');
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> deleteBird() {
    _isLoading = true;
    final String deletedBirdId = selectedBird.id;
    _birds.removeAt(selectedBirdIndex);
    _selectedBirdId = null;
    return http
        .delete(
            'https://flutter-birds.firebaseio.com/birds/$deletedBirdId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> editBird(String title, String description, File image,
      double price, LocationData location) async {
    _isLoading = true;
    notifyListeners();
    String imageUrl = selectedBird.image;
    String imagePath = selectedBird.imagePath;
    if (image != null) {
      final uploadData = await uploadImage(image);
      if (uploadData == null) {
        print('Upload failed');
        return false;
      }
      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'price': price,
      'userEmail': selectedBird.userMail,
      'userId': selectedBird.userId,
      'loc_lat': location.latitude,
      'loc_lng': location.longitude,
      'loc_address': location.address,
    };
    try {
      await http.put(
          'https://flutter-birds.firebaseio.com/birds/${selectedBird.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));
      final Bird updatedBird = Bird(
          id: selectedBird.id,
          location: location,
          title: title,
          description: description,
          image: imageUrl,
          imagePath: imagePath,
          price: price,
          userMail: selectedBird.userMail,
          userId: selectedBird.userId);
      final int sbIndex = _birds.indexWhere((Bird bird) {
        return bird.id == _selectedBirdId;
      });
      _birds[sbIndex] = updatedBird;
      _isLoading = false;
      notifyListeners();
      _selectedBirdId = null;
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Null> fetchBirds({onlyForUser = false,clearExisting=false}) {
    _isLoading = true;
    if(clearExisting){
      _birds=[];
    }
    notifyListeners();
    return http
        .get(
            'https://flutter-birds.firebaseio.com/birds.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Bird> fetchedBirdList = [];
      final Map<String, dynamic> birdListData = json.decode(response.body);
      if (birdListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      birdListData.forEach((String birdId, dynamic birdData) {
        final Bird bird = Bird(
            location: LocationData(
                address: birdData['loc_address'],
                longitude: birdData['loc_lng'],
                latitude: birdData['loc_lat']),
            id: birdId,
            title: birdData['title'],
            description: birdData['description'],
            image: birdData['imageUrl'],
            imagePath: birdData['imagePath'],
            price: birdData['price'],
            userId: birdData['userId'],
            userMail: birdData['userEmail'],
            isFavorite: birdData['favUsers'] == null
                ? false
                : (birdData['favUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedBirdList.add(bird);
      });
      _birds = onlyForUser
          ? fetchedBirdList.where((Bird bird) {
              return bird.userId == _authenticatedUser.id;
            }).toList()
          : fetchedBirdList;
      _birds = fetchedBirdList;
      _isLoading = false;
      notifyListeners();
      _selectedBirdId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  Bird get selectedBird {
    return selectedBirdId == null
        ? null
        : _birds.firstWhere((Bird bird) {
            return bird.id == _selectedBirdId;
          });
  }

  void toggleFavorite(Bird toggledBird) async {
    final bool newStatus = !toggledBird.isFavorite;
    final int toggledBirdIndex = _birds.indexWhere((Bird bird) {
      return bird.id == toggledBird.id;
    });
    final Bird updatedBird = Bird(
        id: toggledBird.id,
        location: toggledBird.location,
        description: toggledBird.description,
        image: toggledBird.image,
        imagePath: toggledBird.imagePath,
        price: toggledBird.price,
        title: toggledBird.title,
        isFavorite: newStatus,
        userId: toggledBird.userId,
        userMail: toggledBird.userMail);
    _birds[toggledBirdIndex] = updatedBird;
    // _selectedBirdId = null;
    notifyListeners();
    http.Response response;
    if (newStatus) {
      response = await http.put(
          'https://flutter-birds.firebaseio.com/birds/${selectedBird.id}/favUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://flutter-birds.firebaseio.com/birds/${selectedBird.id}/favUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Bird updatedBird = Bird(
          id: toggledBird.id,
          location: toggledBird.location,
          description: toggledBird.description,
          image: toggledBird.image,
          imagePath: toggledBird.imagePath,
          price: toggledBird.price,
          title: toggledBird.title,
          isFavorite: !newStatus,
          userId: toggledBird.userId,
          userMail: toggledBird.userMail);
      _birds[toggledBirdIndex] = updatedBird;
      notifyListeners();
    }
    // _selectedBirdId = null;
  }

  void selectBird(String birdId) {
    _selectedBirdId = birdId;
    if (birdId != null) {
      notifyListeners();
    }
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UserModel on ConnectedBirdsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email':
          email, // email and password map keys cannot be changed. API only accepts if named correctly . 'email' and 'password'
      'password': password,
      'returnSecureToken': true,
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyB8vCW80Wr0t2PkP_buNKG-8nae5fa41cU',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    } else {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyB8vCW80Wr0t2PkP_buNKG-8nae5fa41cU',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded';
      _authenticatedUser = User(
        id: responseData['localId'],
        email: email,
        token: responseData['idToken'],
      );
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'token', responseData['idToken']); // Storing token in device.
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Account does not exist';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Invalid password';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final expiryTime = DateTime.parse(expiryTimeString);
      if (expiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final int tokenLifespan = expiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    _selectedBirdId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  User get user {
    return _authenticatedUser;
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin UtilityModel on ConnectedBirdsModel {
  bool get isLoading {
    return _isLoading;
  }
}
