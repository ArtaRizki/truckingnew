import 'package:anugerah_truck/controllers/sj_controller.dart';
import 'package:anugerah_truck/models/surat_jalan_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../router.dart';

class DashboardProvider with ChangeNotifier, DiagnosticableTreeMixin {
  bool _inProgress = true;
  bool get inProgress => _inProgress;

  int _waktu = 1;
  int get waktu => _waktu;

  List<SuratJalanModel> _suratJalan = [];
  List<SuratJalanModel> get suratJalan => _suratJalan;

  List<SuratJalanModel> allSJ = [];

  Widget _buttonChild = Text(
    "Berangkat",
    style: TextStyle(
        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
  );
  Widget get buttonChild => _buttonChild;

  Color _buttonColor = Colors.green;
  Color get buttonColor => _buttonColor;

  setWaktu(int a) {
    _waktu = a;
  }

  void getData() async {
    _inProgress = true;
    allSJ.clear();
    _suratJalan.clear();
    notifyListeners();
    allSJ = await SJController.ListSJ();
    if (waktu == 1) {
      var date = new DateTime.now().toString();
      var dateParse = DateTime.parse(date);
      var waktuFilter = DateFormat("yyyy-MM-dd").format(dateParse);
      _suratJalan = allSJ
          .where((SuratJalanModel i) =>
              ((i.tanggalAmbil.isBefore(dateParse) == true || i.tanggalAmbil.isAtSameMomentAs(dateParse) == true) && i.kembaliKeDepo == "-"))
          .toList();
    } else if (waktu == 2) {
      var date = new DateTime.now().toString();
      var dateParse = DateTime.parse(date);
      var waktuFilter = DateFormat("yyyy-MM-dd").format(dateParse);
      _suratJalan = allSJ
          .where((SuratJalanModel i) =>
              ((i.tanggalAmbil.isAfter(dateParse) == true) && i.berangkat == 0 && i.kembaliKeDepo == "-"))
          .toList();
    } else if (waktu == 3) {
      _suratJalan =
          allSJ.where((SuratJalanModel i) => i.selesaiBongkar != "-").toList();
    }
    _inProgress = false;
    notifyListeners();
  }

  void filter({String keyword, int waktuShow}) {
    _inProgress = true;
    if (waktuShow != null) {
      _waktu = waktuShow;
    }
    notifyListeners();
    _suratJalan = allSJ;
    if (waktu == 1) {
      var date = new DateTime.now().toString();
      var dateParse = DateTime.parse(date);
      var waktuFilter = DateFormat("yyyy-MM-dd").format(dateParse);
      _suratJalan = allSJ
          .where((SuratJalanModel i) =>
              ((i.tanggalAmbil.isBefore(dateParse) == true || i.tanggalAmbil.isAtSameMomentAs(dateParse) == true) && i.kembaliKeDepo == "-"))
          .toList();
    } else if (waktu == 2) {
      var date = new DateTime.now().toString();
      var dateParse = DateTime.parse(date);
      var waktuFilter = DateFormat("yyyy-MM-dd").format(dateParse);
      _suratJalan = allSJ
          .where((SuratJalanModel i) =>
              ((i.tanggalAmbil.isAfter(dateParse) == true) && i.berangkat == 0 && i.kembaliKeDepo == "-"))
          .toList();
    } else if (waktu == 3) {
      _suratJalan =
          allSJ.where((SuratJalanModel i) => i.kembaliKeDepo != "-").toList();
    }
    if (keyword != "" || keyword != null) {
      String key = keyword.toLowerCase();
      _suratJalan = _suratJalan
          .where((SuratJalanModel i) =>
              (i.buktiOrderTrucking.toLowerCase().contains(key) ||
                  i.namaCustomer.toLowerCase().contains(key) ||
                  i.tanggalAmbil.toString().contains(key) ||
                  i.namaPengirim.toLowerCase().contains(key) ||
                  i.namaPenerima.toLowerCase().contains(key)))
          .toList();
    } else {
      _suratJalan = allSJ;
    }
    _inProgress = false;
    notifyListeners();
  }

  void berangkat(int id, scaffold, context) async {
    _buttonChild = CircularProgressIndicator();
    _buttonColor = Colors.white;
    _inProgress = true;
    notifyListeners();
    var status = await SJController.Berangkat(id);
    _inProgress = false;
    _buttonChild = Text(
      "Berangkat",
      style: TextStyle(
          fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
    );
    _buttonColor = Colors.green;
    notifyListeners();
    if (status['status'] == false) {
      final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            status['message'],
            style: TextStyle(color: Colors.white),
          ));
      scaffold.currentState.showSnackBar(snackBar);
    } else {
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //     Router.homeRoute, (Route<dynamic> route) => false);
    }
  }
}
