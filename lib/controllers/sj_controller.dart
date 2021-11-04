import 'dart:convert';
import 'dart:io';

import 'package:anugerah_truck/controllers/user_controller.dart';
import 'package:anugerah_truck/models/driver_model.dart';
import 'package:anugerah_truck/models/surat_jalan_model.dart';
import 'package:anugerah_truck/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../global_config.dart';

class SJController {
  static Future<List<SuratJalanModel>> ListSJ() async {
    try {
      UserModel dataDriver = await UserController.UserData();
      Logger().e("tes123" + dataDriver.toString());
      if (dataDriver == null) {
        return [];
      }
      FormData formData = new FormData.fromMap({'id': dataDriver.idSup});

      Response response =
          await Dio().post(GlobalConfig().ListSJ(), data: formData);
      List<dynamic> json = jsonDecode(response.toString());

      List<SuratJalanModel> userData = List<SuratJalanModel>.from(
          json.map((i) => suratJalanModelFromJson(jsonEncode(i))));

      // if (keyword != null) {
      //   String key = keyword.toLowerCase();
      //   userData = userData
      //       .where((SuratJalanModel i) => (
      //           // i.alamatPenerima.toLowerCase().contains(key) ||
      //           //   i.namaPenerima.toLowerCase().contains(key) ||
      //           //   i.kotaPenerima.toLowerCase().contains(key) ||
      //           //   i.alamatPengirim.toLowerCase().contains(key) ||
      //           //   i.namaPengirim.toLowerCase().contains(key) ||
      //           //   i.kotaPengirim.toLowerCase().contains(key)
      //           i.buktiOrderTrucking.toLowerCase().contains(key) ||
      //               i.namaCustomer.toLowerCase().contains(key) ||
      //               i.tanggalAmbil.toString().contains(key) ||
      //               i.namaPengirim.toLowerCase().contains(key) ||
      //               i.namaPenerima.toLowerCase().contains(key)))
      //       .toList();
      // }

      return userData;
    } catch (_) {
      print(_);
      return [];
    }
  }

  static Future Berangkat(int id) async {
    FormData formData = new FormData.fromMap({'ID': id});
    try {
      Response response =
          await Dio().post(GlobalConfig().Berangkat(), data: formData);
      var json = jsonDecode(response.toString());

      return json;
    } catch (_) {
      return {'status': false, 'message': 'Terjadi masalah dengan server'};
    }
  }

  static Future updateStatus(
      int idTSJ, String note, String status, String fileURL, position) async {
    try {
      // file:///storage/emulated/0/DCIM/Camera/IMG_20200218_072725.jpg
      print("masuk sini 4.3.1");
      var strSplit = fileURL.split("/");
      print("masuk sini 4.3.2");
      print("masuk upload 1");
      print(fileURL);

      var file = File(fileURL);
      print("masuk upload 2");
      Logger().e(fileURL);

      // var file2 = File("/storage/emulated/0/Android/data/com.example.anugerah_trucking.dev/files/Pictures/scaled_34cbb603-ed2b-447e-aed3-d2fbce1e8c9a7308930007747896631.jpg");
      //  if (await file.exists()) {
      //    Logger().e("file ada");
      //  } else {
      //    Logger().e("file kosong");
      //  }

      print(position.longitude.toString());
      String long = position.longitude.toString();
      String lat = position.latitude.toString();

      FormData formData = new FormData.fromMap({
        "ID": idTSJ.toString(),
        "IdTSJ": idTSJ.toString(),
        "long": long,
        "lat": lat,
        "note": note,
        "status": status,
        "files": [
          await MultipartFile.fromFile(fileURL,
              filename: strSplit[strSplit.length - 1])
        ]
      });

      print(formData.toString());
      Response response =
          await Dio().post(GlobalConfig().UpdateStatus(), data: formData);
      // .catchError((error) => return -1);
      print(response.toString());

      var json = jsonDecode(response.toString());

      if (await file.exists()) {
        // file exits, it is safe to call delete on it
        await file.delete();
      }

      return json;
    } catch (_) {
      print(_);
      return {'status': false, 'msg': 'Terjadi masalah dengan server'};
    }
  }
}
