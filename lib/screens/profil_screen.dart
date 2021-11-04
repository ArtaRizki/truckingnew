import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/input_decoration.dart';
import '../providers/profil_provider.dart';

class ProfilScreen extends StatefulWidget {
  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  TextEditingController _nameCon = new TextEditingController();
  TextEditingController _emailCon = new TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context
        .read<ProfilProvider>()
        .getData(nameCon: _nameCon, emailCon: _emailCon));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: FlutterLogo(),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Konfirmasi'),
                      content: Text("Apakah anda yakin akan logout?"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Tidak'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Ya'),
                          onPressed: () {
                            context.read<ProfilProvider>().logOut(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
        ],
      ),
      body: context.watch<ProfilProvider>().inProgress == true
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Form(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _nameCon,
                          style: TextStyle(fontSize: 20),
                          readOnly: true,
                          decoration: profilTextDecoration(
                            "Nama",
                            Icon(Icons.person),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          style: TextStyle(fontSize: 20),
                          readOnly: true,
                          controller: _emailCon,
                          decoration: profilTextDecoration(
                            "Username",
                            Icon(Icons.email),
                          ),
                        ),
                        // SizedBox(height: 20),
                        // TextFormField(
                        //   style: TextStyle(fontSize: 20),
                        //   obscureText: true,
                        //   decoration: profilTextDecoration(
                        //     "Password",
                        //     Icon(Icons.lock),
                        //   ),
                        // ),
                        // SizedBox(height: 20),
                        // TextFormField(
                        //   style: TextStyle(fontSize: 20),
                        //   obscureText: true,
                        //   decoration: profilTextDecoration(
                        //     "Ketik Ulang Password",
                        //     Icon(Icons.lock),
                        //   ),
                        // ),
                        // Expanded(
                        //   child: Container()
                        // ),
                        // SizedBox(
                        //     width: double.infinity,
                        //     child: FlatButton(
                        //       padding: EdgeInsets.symmetric(vertical: 15),
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(30)),
                        //       color: Colors.green,
                        //       onPressed: () {},
                        //       child: Text("Simpan"),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigation(context, 1),
    );
  }
}
