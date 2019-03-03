import 'package:udemy_project/scoped_models/connected_birds.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model with ConnectedBirdsModel,BirdsModel,UserModel,UtilityModel{

}