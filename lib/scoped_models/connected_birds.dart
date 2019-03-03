import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:udemy_project/models/bird.dart';
import 'package:udemy_project/models/user.dart';
import 'dart:convert';
import 'dart:async';
import 'package:udemy_project/models/auth.dart';

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

  Future<bool> addBird(String title, String description, String image,
      double price, String address) async {
    _isLoading = true;
    notifyListeners();
    // Only functions below can change main list of Birds.
    final Map<String, dynamic> birdData = {
      'title': title,
      'description': description,
      'image':
          'http://skybirdsales.co.uk/wp-content/uploads/2014/08/fischersmasked_white_edited_1.jpg',
      'price': price,
      'address': address,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };
    try {
      final http.Response response = await http.post(
          // await = wait process to finish.
          'https://flutter-birds.firebaseio.com/birds.json',
          body: json.encode(birdData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Bird bird = Bird(
          id: responseData['name'],
          address: address,
          title: title,
          description: description,
          image: image,
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

  Future<bool> deleteBird() {
    _isLoading = true;
    final String deletedBirdId = selectedBird.id;
    _birds.removeAt(selectedBirdIndex);
    _selectedBirdId = null;
    return http
        .delete(
            'https://flutter-birds.firebaseio.com/birds/$deletedBirdId.json')
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

  Future<bool> editBird(String title, String description, String image,
      double price, String address) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'http://skybirdsales.co.uk/wp-content/uploads/2014/08/fischersmasked_white_edited_1.jpg',
      'price': price,
      'address': address,
      'userEmail': selectedBird.userMail,
      'userId': selectedBird.userId,
    };
    return http
        .put(
            'https://flutter-birds.firebaseio.com/birds/${selectedBird.id}.json',
            body: json.encode(updateData))
        .then((http.Response response) {
      final Bird updatedBird = Bird(
          id: selectedBird.id,
          address: address,
          title: title,
          description: description,
          image: image,
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
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchBirds() {
    _isLoading = true;
    notifyListeners();
    return http
        .get('https://flutter-birds.firebaseio.com/birds.json')
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
          address: birdData['address'],
          id: birdId,
          title: birdData['title'],
          description: birdData['description'],
          image: birdData['image'],
          price: birdData['price'],
          userId: birdData['userId'],
          userMail: birdData['userEmail'],
        );
        fetchedBirdList.add(bird);
      });
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

  void toggleFavorite() {
    final Bird selectedBird = _birds[selectedBirdIndex];
    final bool newStatus = !selectedBird.isFavorite;
    final Bird updatedBird = Bird(
        id: selectedBird.id,
        address: selectedBird.address,
        description: selectedBird.description,
        image: selectedBird.image,
        price: selectedBird.price,
        title: selectedBird.title,
        isFavorite: newStatus,
        userId: _authenticatedUser.id,
        userMail: _authenticatedUser.email);
    _birds[selectedBirdIndex] = updatedBird;
    _selectedBirdId = null;
    notifyListeners();
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
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Account does not exist';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Invalid password';
    }
    else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }
}

mixin UtilityModel on ConnectedBirdsModel {
  bool get isLoading {
    return _isLoading;
  }
}
