import 'dart:async';
import 'dart:io';

import 'package:anugerah_truck/controllers/sj_controller.dart';
import 'package:anugerah_truck/models/surat_jalan_model.dart';
import 'package:anugerah_truck/providers/dashboard_provider.dart';
import 'package:anugerah_truck/widgets/camera_view.dart';
import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as L;
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as P;
import 'package:provider/provider.dart';
import 'package:anugerah_truck/providers/dashboard_provider.dart';

import '../global_config.dart';
import '../router.dart';
import '../widgets/input_decoration.dart';

enum StatusTruck {
  AntriMuat,
  SelesaiMuat,
  AntriBongkar,
  SelesaiBongkar,
  Kembali,
  MasalahDijalan
}

class FormScreen extends StatefulWidget {
  final SuratJalanModel suratJalan;

  const FormScreen(this.suratJalan);
  @override
  _FormScreenState createState() => _FormScreenState(this.suratJalan);
}

class _FormScreenState extends State<FormScreen> {
  final SuratJalanModel suratJalan;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraController _controller;

  Future<void> _initializeControllerFuture;

  File _antriMuatFile;
  final _antriMuatPicker = ImagePicker();
  TextEditingController _antriMuatText = new TextEditingController();

  File _selesaiMuatFile;
  final _selesaiMuatPicker = ImagePicker();
  TextEditingController _selesaiMuatText = new TextEditingController();

  File _antriBongkarFile;
  final _antriBongkarPicker = ImagePicker();
  TextEditingController _antriBongkarText = new TextEditingController();

  File _selesaiBongkarFile;
  final _selesaiBongkarPicker = ImagePicker();
  TextEditingController _selesaiBongkarText = new TextEditingController();

  File _masalahFile;
  final _masalahPicker = ImagePicker();
  TextEditingController _masalahText = new TextEditingController();

  File _kembaliFile;
  final _kembaliPicker = ImagePicker();
  TextEditingController _kembaliText = new TextEditingController();

  bool inProgress = false;

  bool inProgressMasalah = false;

  bool canBerangkat = false;

  _FormScreenState(this.suratJalan);

  L.Location location = new L.Location();

  bool _serviceEnabled;
  L.LocationData _locationData;

  Future getImage(picker, file) async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 300);

    setState(() {
      file = File(pickedFile.path);
    });
  }

  void submit(StatusTruck status) async {
    File fileUpload;
    String textUpload;
    String textStatus;
    bool gagalKendala = false;
    String pesan = "";

    switch (status) {
      case StatusTruck.AntriMuat:
        fileUpload = _antriMuatFile;
        textUpload = _antriMuatText.text;
        textStatus = "Antri Muat";
        break;
      case StatusTruck.SelesaiMuat:
        fileUpload = _selesaiMuatFile;
        textUpload = _selesaiMuatText.text;
        textStatus = "Selesai Muat";
        break;
      case StatusTruck.AntriBongkar:
        fileUpload = _antriBongkarFile;
        textUpload = _antriBongkarText.text;
        textStatus = "Antri Bongkar";
        break;
      case StatusTruck.SelesaiBongkar:
        fileUpload = _selesaiBongkarFile;
        textUpload = _selesaiBongkarText.text;
        textStatus = "Selesai Bongkar";
        print("masuk sini");
        break;
      case StatusTruck.Kembali:
        fileUpload = _kembaliFile;
        textUpload = _kembaliText.text;
        textStatus = "Kembali ke depo";
        break;
      case StatusTruck.MasalahDijalan:
        fileUpload = _masalahFile;
        textUpload = _masalahText.text;
        textStatus = "Masalah di jalan";
        setState(() {
          inProgressMasalah = true;
        });
        break;
    }

    Timer(Duration(seconds: 60), () {
      final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Execution time out",
            style: TextStyle(color: Colors.white),
          ));
      if (inProgress == true || inProgressMasalah == true) {
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }

      setState(() {
        inProgress = false;
        inProgressMasalah = false;
      });
    });

    _serviceEnabled = await location.serviceEnabled();
    print("masuk sini 1");
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Nyalakan GPS untuk menyimpan data",
              style: TextStyle(color: Colors.white),
            ));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        setState(() {
          inProgress = false;
          inProgressMasalah = false;
        });

        return;
      }
    }

    if (status == StatusTruck.MasalahDijalan) {
      print("masuk sini 2");
      setState(() {
        inProgressMasalah = true;
      });
    } else {
      setState(() {
        inProgress = true;
      });
    }
    bool isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();

    Map<P.Permission, P.PermissionStatus> statuses = await [
      P.Permission.location,
    ].request();
    print("masuk sini 3");
    if (isLocationServiceEnabled == false) {
      final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Silahkan nyalakan nyalakan GPS untuk submit",
            style: TextStyle(color: Colors.white),
          ));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      print("gps mati");
    } else if (await P.Permission.location.isGranted == false) {
      Fluttertoast.showToast(
          msg: "Ijinkan aplikasi untuk mengakses lokasi",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      AppSettings.openAppSettings();
      // final snackBar = SnackBar(
      //     backgroundColor: Colors.red,
      //     content: Text(
      //       "Silahkan ijinkan akses GPS",
      //       style: TextStyle(color: Colors.white),
      //     ));
      // _scaffoldKey.currentState.showSnackBar(snackBar);
      // print("gps mati");
    } else if (fileUpload == null) {
      final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Foto belum diisi",
            style: TextStyle(color: Colors.white),
          ));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else if (textUpload == "" && status == StatusTruck.MasalahDijalan) {
      final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Keterangan belum diisi",
            style: TextStyle(color: Colors.white),
          ));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      gagalKendala = true;
    } else {
      print("masuk sini 4");
      var geo = Geolocator();
      pesan = "Gagal mendapatkan lokasi";
      print("masuk sini 4.1");
      // geo.forceAndroidLocationManager = true;
      print("masuk sini 4.2");
      var data;
      try {
        Position position = await Geolocator.getLastKnownPosition();
        print("masuk sini 4.3");
        data = await SJController.updateStatus(
            suratJalan.id, textUpload, textStatus, fileUpload.path, position);
        print("masuk sini 4.4");
      } catch (e) {
        setState(() {
          inProgress = false;
          inProgressMasalah = false;
          if (gagalKendala == false) {
            _masalahText.text = "";
            _masalahFile = null;
          }
        });
        final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.toString(),
              style: TextStyle(color: Colors.white),
            ));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      }
      print("masuk sini 5");
      if (data['status'] == true) {
        final snackBar = SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
              data['msg'],
              style: TextStyle(color: Colors.white),
            ));
        _scaffoldKey.currentState.showSnackBar(snackBar);

        switch (status) {
          case StatusTruck.AntriMuat:
            setState(() {
              suratJalan.antriMuat = _antriMuatText.text;
            });
            break;
          case StatusTruck.SelesaiMuat:
            setState(() {
              suratJalan.selesaiMuat = _selesaiMuatText.text;
            });
            break;
          case StatusTruck.AntriBongkar:
            setState(() {
              suratJalan.antriBongkar = _antriBongkarText.text;
            });
            break;
          case StatusTruck.SelesaiBongkar:
            setState(() {
              suratJalan.selesaiBongkar = _selesaiBongkarText.text;
            });
            break;
          case StatusTruck.Kembali:
            setState(() {
              suratJalan.kembaliKeDepo = _kembaliText.text;
            });
            break;
          case StatusTruck.MasalahDijalan:
            // TODO: Handle this case.
            break;
        }
      } else {
        final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              data['msg'],
              style: TextStyle(color: Colors.white),
            ));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
    setState(() {
      inProgress = false;
      inProgressMasalah = false;
      if (gagalKendala == false) {
        _masalahText.text = "";
        _masalahFile = null;
      }
    });
  }

  berangkat() async {
    Timer(Duration(seconds: 60), () {
      final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Execution Time Out",
            style: TextStyle(color: Colors.white),
          ));
      if (inProgress == true) {
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }

      setState(() {
        inProgress = false;
      });
    });

    setState(() {
      inProgress = true;
    });
    bool isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();

    Map<P.Permission, P.PermissionStatus> statuses = await [
      P.Permission.location,
    ].request();
    if (isLocationServiceEnabled == false) {
      final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Silahkan nyalakan nyalakan GPS untuk submit",
            style: TextStyle(color: Colors.white),
          ));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      print("gps mati");
    } else if (await P.Permission.location.isGranted == false) {
      Fluttertoast.showToast(
          msg: "Ijinkan aplikasi untuk mengakses lokasi",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      AppSettings.openAppSettings();
    } else {
      var status = await SJController.Berangkat(suratJalan.id);

      if (status['status'] == false) {
        final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              status['message'],
              style: TextStyle(color: Colors.white),
            ));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        setState(() {
          suratJalan.berangkat = 1;
        });
      }
    }

    setState(() {
      inProgress = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(suratJalan.antriMuat);
    _antriMuatText.text =
        suratJalan.antriMuat == "-" ? "" : suratJalan.antriMuat;

    _selesaiMuatText.text =
        suratJalan.selesaiMuat == "-" ? "" : suratJalan.selesaiMuat;

    _antriBongkarText.text =
        suratJalan.antriBongkar == "-" ? "" : suratJalan.antriBongkar;

    _selesaiBongkarText.text =
        suratJalan.selesaiBongkar == "-" ? "" : suratJalan.selesaiBongkar;

    _kembaliText.text =
        suratJalan.kembaliKeDepo == "-" ? "" : suratJalan.kembaliKeDepo;

    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var waktuFilter = DateFormat("yyyy-MM-dd").format(dateParse);

    if (suratJalan.tanggalAmbil.isBefore(dateParse) == true ||
        suratJalan.tanggalAmbil.isAtSameMomentAs(dateParse)) {
      canBerangkat = true;
    }

    if (suratJalan.tanggalAmbil.isAfter(dateParse) == true) {
      canBerangkat = false;
    }

    // onStart();
  }

  var cameras;

  // void onStart() async {
  //   cameras = await availableCameras();

  //   _controller = CameraController(
  //     // Get a specific camera from the list of available cameras.
  //     cameras.first,
  //     // Define the resolution to use.
  //     ResolutionPreset.low,
  //   );
  //   await _controller.initialize();
  //   Logger().w("camera intialized");
  //   Logger().w("camera intialized 23");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Form", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: <Widget>[
              // TextFormField(
              //   style: TextStyle(fontSize: 20),
              //   enabled: false,
              //   decoration: formTextDecoration("No. Bukti Order"),
              //   initialValue: suratJalan.buktiOrderTrucking,
              // ),
              // SizedBox(height: 10),
              // TextFormField(
              //   style: TextStyle(fontSize: 20),
              //   enabled: false,
              //   minLines: 3,
              //   maxLines: 4,
              //   decoration: formTextDecoration("Alamat Ambil"),
              //   initialValue: suratJalan.alamatPengirim,
              // ),
              // SizedBox(height: 10),
              // TextFormField(
              //   style: TextStyle(fontSize: 20),
              //   enabled: false,
              //   minLines: 3,
              //   maxLines: 4,
              //   decoration: formTextDecoration("Alamat Kirim"),
              //   initialValue: suratJalan.alamatPenerima,
              // ),
              // TextFormField(
              //   style: TextStyle(fontSize: 20),
              //   enabled: false,
              //   decoration: formTextDecoration("Jenis"),
              //   initialValue: suratJalan.jenis,
              // ),
              // SizedBox(height: 10),
              TextFormField(
                style: TextStyle(fontSize: 20),
                enabled: false,
                decoration: formTextDecoration("Customer"),
                initialValue: suratJalan.namaCustomer,
              ),
              SizedBox(height: 10),
              TextFormField(
                style: TextStyle(fontSize: 20),
                enabled: false,
                decoration: formTextDecoration("Tanggal Ambil"),
                initialValue:
                    DateFormat("dd/MM/yyyy").format(suratJalan.tanggalAmbil),
              ),
              SizedBox(height: 10),
              TextFormField(
                style: TextStyle(fontSize: 20),
                enabled: false,
                decoration: formTextDecoration("Depo"),
                initialValue: suratJalan.depo,
              ),
              SizedBox(height: 10),
              TextFormField(
                  style: TextStyle(fontSize: 20),
                  enabled: false,
                  decoration: formTextDecoration("Tujuan"),
                  initialValue: suratJalan.namaPenerima),
              SizedBox(height: 10),
              TextFormField(
                style: TextStyle(fontSize: 20),
                enabled: false,
                minLines: 3,
                maxLines: 4,
                decoration: formTextDecoration("Alamat"),
                initialValue: suratJalan.alamatPengirim,
              ),
              SizedBox(height: 10),
              TextFormField(
                  style: TextStyle(fontSize: 20),
                  enabled: false,
                  decoration: formTextDecoration("Jumlah Container"),
                  initialValue: suratJalan.jumlahContainer.toString() +
                      " x " +
                      suratJalan.jenisContainer),
              SizedBox(height: 10),
              suratJalan.berangkat == 1 || canBerangkat == false
                  ? Container()
                  : SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          color:
                              inProgress == false ? Colors.green : Colors.grey,
                          onPressed: (inProgress == true ||
                                  suratJalan.tombolberangkat == 0)
                              ? null
                              : () {
                                  berangkat();
                                  // context.read<DashboardProvider>().berangkat(
                                  //     suratJalan.id, _scaffoldKey, context);
                                },
                          child: inProgress == false
                              ? Text("Berangkat")
                              : CircularProgressIndicator()),
                    ),
              SizedBox(height: 10),

              //Antri Muat
              suratJalan.berangkat == 0
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: ExpandablePanel(
                        collapsed: Text(''),
                        header: Padding(
                          padding: EdgeInsets.only(top: 15, left: 15),
                          child: Text(
                            "Pengambilan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        expanded: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: BorderRadius.circular(5),
                            border: Border(
                              left: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              suratJalan.antriMuat != "-"
                                  ? Container()
                                  : GestureDetector(
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: _antriMuatFile == null
                                            ? Center(
                                                child: Icon(Icons.add_a_photo,
                                                    size: 50))
                                            : Image.file(_antriMuatFile),
                                      ),
                                      onTap: () async {
                                        var tempFile =
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CameraExampleHome()));
                                        Logger().w("back buttopn");
                                        setState(() {
                                          if (tempFile != null)
                                            _antriMuatFile =
                                                File(tempFile.path);
                                        });
                                        // var pickedFile =
                                        //     await _antriMuatPicker.getImage(
                                        //         source: ImageSource.camera, imageQuality: 50, maxWidth: 300);

                                        // setState(() {
                                        //   if (tes2 != null)
                                        //     _antriMuatFile =
                                        //         File(tes2.path);
                                        // });
                                      },
                                    ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(fontSize: 20),
                                minLines: 3,
                                maxLines: 4,
                                enabled:
                                    suratJalan.antriMuat == "-" ? true : false,
                                decoration: formTextDecoration2("Keterangan"),
                                controller: _antriMuatText,
                              ),
                              SizedBox(height: 10),
                              suratJalan.antriMuat != "-" ||
                                      suratJalan.berangkat == 0
                                  ? Container()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: FlatButton(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        color: Colors.green,
                                        onPressed: inProgress == true
                                            ? null
                                            : () async {
                                                submit(StatusTruck.AntriMuat);
                                              },
                                        child: inProgress == false
                                            ? Text("Simpan")
                                            : CircularProgressIndicator(),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
              suratJalan.berangkat == 0
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      height: 10,
                    ),
              SizedBox(
                height: 10,
              ),

              //Selesai Muat
              suratJalan.antriMuat == "-"
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: ExpandablePanel(
                        collapsed: Text(''),
                        header: Padding(
                          padding: EdgeInsets.only(top: 15, left: 15),
                          child: Text(
                            "Sampai Tujuan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        expanded: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: BorderRadius.circular(5),
                            border: Border(
                              left: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              suratJalan.selesaiMuat != "-"
                                  ? Container()
                                  : GestureDetector(
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: _selesaiMuatFile == null
                                            ? Center(
                                                child: Icon(Icons.add_a_photo,
                                                    size: 50))
                                            : Image.file(_selesaiMuatFile),
                                      ),
                                      onTap: () async {
                                        // var pickedFile =
                                        //     await _selesaiMuatPicker.getImage(
                                        //         source: ImageSource.camera, imageQuality: 50, maxWidth: 300);
                                        var pickedFile =
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CameraExampleHome()));

                                        setState(() {
                                          if (pickedFile != null)
                                            _selesaiMuatFile =
                                                File(pickedFile.path);
                                        });
                                      },
                                    ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(fontSize: 20),
                                minLines: 3,
                                maxLines: 4,
                                enabled: suratJalan.selesaiMuat == "-"
                                    ? true
                                    : false,
                                decoration: formTextDecoration2("Keterangan"),
                                controller: _selesaiMuatText,
                              ),
                              SizedBox(height: 10),
                              suratJalan.selesaiMuat != "-" ||
                                      suratJalan.antriMuat == "-"
                                  ? Container()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: FlatButton(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        color: Colors.green,
                                        onPressed: inProgress == true
                                            ? null
                                            : () async {
                                                submit(StatusTruck.SelesaiMuat);
                                              },
                                        child: inProgress == false
                                            ? Text("Simpan")
                                            : CircularProgressIndicator(),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
              suratJalan.antriMuat == "-"
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      height: 10,
                    ),
              SizedBox(
                height: 10,
              ),

              //Antri Bongkar
              suratJalan.selesaiMuat == "-"
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: ExpandablePanel(
                        collapsed: Text(''),
                        header: Padding(
                          padding: EdgeInsets.only(top: 15, left: 15),
                          child: Text(
                            "Proses ditujuan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        expanded: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: BorderRadius.circular(5),
                            border: Border(
                              left: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              suratJalan.antriBongkar != "-"
                                  ? Container()
                                  : GestureDetector(
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: _antriBongkarFile == null
                                            ? Center(
                                                child: Icon(Icons.add_a_photo,
                                                    size: 50))
                                            : Image.file(_antriBongkarFile),
                                      ),
                                      onTap: () async {
                                        // var pickedFile =
                                        //     await _antriBongkarPicker.getImage(
                                        //         source: ImageSource.camera, imageQuality: 50, maxWidth: 300);
                                        var pickedFile =
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CameraExampleHome()));

                                        setState(() {
                                          if (pickedFile != null)
                                            _antriBongkarFile =
                                                File(pickedFile.path);
                                        });
                                      },
                                    ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(fontSize: 20),
                                minLines: 3,
                                maxLines: 4,
                                enabled: suratJalan.antriBongkar == "-"
                                    ? true
                                    : false,
                                decoration: formTextDecoration2("Keterangan"),
                                controller: _antriBongkarText,
                              ),
                              SizedBox(height: 10),
                              suratJalan.antriBongkar != "-" ||
                                      suratJalan.selesaiMuat == "-"
                                  ? Container()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: FlatButton(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        color: Colors.green,
                                        onPressed: inProgress == true
                                            ? null
                                            : () async {
                                                submit(
                                                    StatusTruck.AntriBongkar);
                                              },
                                        child: inProgress == false
                                            ? Text("Simpan")
                                            : CircularProgressIndicator(),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
              suratJalan.selesaiMuat == "-"
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      height: 10,
                    ),
              SizedBox(
                height: 10,
              ),

              //Selesai Bongkar
              suratJalan.antriBongkar == "-"
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: ExpandablePanel(
                        collapsed: Text(''),
                        header: Padding(
                          padding: EdgeInsets.only(top: 15, left: 15),
                          child: Text(
                            "Selesai ditujuan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        expanded: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: BorderRadius.circular(5),
                            border: Border(
                              left: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              suratJalan.selesaiBongkar != "-"
                                  ? Container()
                                  : GestureDetector(
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: _selesaiBongkarFile == null
                                            ? Center(
                                                child: Icon(Icons.add_a_photo,
                                                    size: 50))
                                            : Image.file(_selesaiBongkarFile),
                                      ),
                                      onTap: () async {
                                        // var pickedFile =
                                        //     await _selesaiBongkarPicker
                                        //         .getImage(
                                        //             source: ImageSource.camera, imageQuality: 50, maxWidth: 300);
                                        var pickedFile =
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CameraExampleHome()));

                                        setState(() {
                                          if (pickedFile != null)
                                            _selesaiBongkarFile =
                                                File(pickedFile.path);
                                        });
                                      },
                                    ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(fontSize: 20),
                                minLines: 3,
                                maxLines: 4,
                                enabled: suratJalan.selesaiBongkar == "-"
                                    ? true
                                    : false,
                                decoration: formTextDecoration2("Keterangan"),
                                controller: _selesaiBongkarText,
                              ),
                              SizedBox(height: 10),
                              suratJalan.selesaiBongkar != "-" ||
                                      suratJalan.antriBongkar == "-"
                                  ? Container()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: FlatButton(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        color: Colors.green,
                                        onPressed: inProgress == true
                                            ? null
                                            : () async {
                                                submit(
                                                    StatusTruck.SelesaiBongkar);
                                              },
                                        child: inProgress == false
                                            ? Text("Simpan")
                                            : CircularProgressIndicator(),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
              suratJalan.antriBongkar == "-"
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      height: 10,
                    ),
              SizedBox(
                height: 10,
              ),

              //Kembali ke depo
              suratJalan.selesaiBongkar == "-"
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: ExpandablePanel(
                        collapsed: Text(''),
                        header: Padding(
                          padding: EdgeInsets.only(top: 15, left: 15),
                          child: Text(
                            "Kembali ke Depo",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        expanded: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: BorderRadius.circular(5),
                            border: Border(
                              left: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              suratJalan.kembaliKeDepo != "-"
                                  ? Container()
                                  : GestureDetector(
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: _kembaliFile == null
                                            ? Center(
                                                child: Icon(Icons.add_a_photo,
                                                    size: 50))
                                            : Image.file(_kembaliFile),
                                      ),
                                      onTap: () async {
                                        // var pickedFile =
                                        //     await _kembaliPicker.getImage(
                                        //         source: ImageSource.camera, imageQuality: 50, maxWidth: 300);
                                        var pickedFile =
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CameraExampleHome()));

                                        setState(() {
                                          _kembaliFile = File(pickedFile.path);
                                        });
                                      },
                                    ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(fontSize: 20),
                                minLines: 3,
                                maxLines: 4,
                                enabled: suratJalan.kembaliKeDepo == "-"
                                    ? true
                                    : false,
                                decoration: formTextDecoration2("Keterangan"),
                                controller: _kembaliText,
                              ),
                              SizedBox(height: 10),
                              suratJalan.kembaliKeDepo != "-" ||
                                      suratJalan.selesaiMuat == "-"
                                  ? Container()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: FlatButton(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        color: Colors.green,
                                        onPressed: inProgress == true
                                            ? null
                                            : () async {
                                                submit(StatusTruck.Kembali);
                                              },
                                        child: inProgress == false
                                            ? Text("Simpan")
                                            : CircularProgressIndicator(),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
              suratJalan.selesaiBongkar == "-"
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      height: 10,
                    ),
              SizedBox(
                height: 10,
              ),

              //Masalah Dijalan
              (suratJalan.kembaliKeDepo != "-" || suratJalan.berangkat == 0)
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: ExpandablePanel(
                        collapsed: Text(''),
                        header: Padding(
                          padding: EdgeInsets.only(top: 15, left: 15),
                          child: Text(
                            "Kendala",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        expanded: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: BorderRadius.circular(5),
                            border: Border(
                              left: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: _masalahFile == null
                                      ? Center(
                                          child:
                                              Icon(Icons.add_a_photo, size: 50))
                                      : Image.file(_masalahFile),
                                ),
                                onTap: () async {
                                  // var pickedFile = await _masalahPicker
                                  //     .getImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 500);
                                  var pickedFile = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              CameraExampleHome()));

                                  setState(() {
                                    if (pickedFile != null)
                                      _masalahFile = File(pickedFile.path);
                                  });
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(fontSize: 20),
                                minLines: 3,
                                maxLines: 4,
                                decoration: formTextDecoration2("Keterangan"),
                                controller: _masalahText,
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: FlatButton(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  color: Colors.green,
                                  onPressed: inProgressMasalah == true
                                      ? null
                                      : () async {
                                          submit(StatusTruck.MasalahDijalan);
                                        },
                                  child: inProgressMasalah == false
                                      ? Text("Simpan")
                                      : CircularProgressIndicator(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              (suratJalan.selesaiBongkar != "-" || suratJalan.berangkat == 0)
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      height: 10,
                    ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
