import 'dart:convert';

import 'package:flutter/foundation.dart';

DriverModel driverModelFromJson(String str) => DriverModel.fromJson(json.decode(str));

String driverModelToJson(DriverModel data) => json.encode(data.toJson());

class DriverModel {
    DriverModel({
        @required this.name,
        @required this.email,
        @required this.idMSup,
    });

    String name;
    String email;
    int idMSup;

    factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        name: json["Name"],
        email: json["Email"],
        idMSup: json["IdMSup"],
    );

    Map<String, dynamic> toJson() => {
        "Name": name,
        "Email": email,
        "IdMSup": idMSup,
    };
}