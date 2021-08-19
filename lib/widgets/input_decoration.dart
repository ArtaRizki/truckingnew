import 'package:flutter/material.dart';

loginTextDecoration(String label, Icon icon) {
  return InputDecoration(
    hintText: label,
    filled: true,
    fillColor: Colors.white,
    prefixIcon: icon,
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(30.0),
      borderSide: new BorderSide(width: 0.1),
    ),
  );
}

profilTextDecoration(String label, Icon icon) {
  return InputDecoration(
    hintText: label,
    filled: true,
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey),
    fillColor: Colors.white,
    prefixIcon: icon,
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(30.0),
      borderSide: new BorderSide(width: 0.1),
    ),
  );
}

formTextDecoration(String label) {
  return InputDecoration(
    hintText: label,
    filled: true,
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey),
    fillColor: Colors.white,
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(10.0),
      borderSide: new BorderSide(width: 0.1),
    ),
  );
}

formTextDecoration2(String label) {
  return InputDecoration(
    hintText: label,
    filled: true,
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey),
    fillColor: Colors.white,
    alignLabelWithHint: true,
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(10.0),
      borderSide: new BorderSide(width: 0.1),
    ),
  );
}