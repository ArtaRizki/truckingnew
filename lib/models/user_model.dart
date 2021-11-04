import 'package:flutter/foundation.dart';
import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
    UserModel({
        @required this.id,
        @required this.name,
        @required this.email,
        @required this.idSup,
    });

    int id;
    String name;
    String email;
    int idSup;

    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        idSup: json["idSup"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "idSup": idSup,
    };
}