import 'package:anugerah_truck/controllers/sj_controller.dart';
import 'package:anugerah_truck/models/surat_jalan_model.dart';
import 'package:anugerah_truck/providers/dashboard_provider.dart';
import 'package:anugerah_truck/widgets/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../global_config.dart';
import '../widgets/input_decoration.dart';
import '../widgets/bottom_navigation.dart';
import '../router.dart' as R;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String search = "";

  // final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() => context.read<DashboardProvider>().getData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: Padding(
            padding: EdgeInsets.symmetric(vertical: 10), child: FlutterLogo()),
        title: Text('Home',
            style: TextStyle(
              color: Colors.black,
            )),
        backgroundColor: Colors.white,
        titleSpacing: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext bc) {
                  return SingleChildScrollView(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            autofocus: true,
                            initialValue: search,
                            style: TextStyle(fontSize: 20),
                            textInputAction: TextInputAction.search,
                            onChanged: (String s) {
                              search = s;
                              context
                                  .read<DashboardProvider>()
                                  .filter(keyword: s);
                            },
                            decoration: loginTextDecoration(
                              "Search",
                              Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            color: Colors.blue,
          ),
        ],
      ),
      body: Column(children: <Widget>[
        SizedBox(height: 10),
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(width: 10),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: context.watch<DashboardProvider>().waktu == 1
                      ? Colors.blue
                      : Colors.grey,
                  onPressed: () {
                    context
                        .read<DashboardProvider>()
                        .filter(waktuShow: 1, keyword: "");
                  },
                  child:
                      Text("Hari Ini", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: context.watch<DashboardProvider>().waktu == 2
                      ? Colors.blue
                      : Colors.grey,
                  onPressed: () {
                    context
                        .read<DashboardProvider>()
                        .filter(waktuShow: 2, keyword: "");
                  },
                  child: Text("Besok", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: context.watch<DashboardProvider>().waktu == 3
                      ? Colors.blue
                      : Colors.grey,
                  onPressed: () {
                    context
                        .read<DashboardProvider>()
                        .filter(waktuShow: 3, keyword: "");
                  },
                  child: Text("Selesai", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        SizedBox(height: 15),
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              // SliverAppBar(
              //   floating: true,
              //   leading: Padding(
              //       padding: EdgeInsets.symmetric(vertical: 10),
              //       child: FlutterLogo()),
              //   title: Text('Home',
              //       style: TextStyle(
              //         color: Colors.black,
              //       )),
              //   backgroundColor: Colors.white,
              //   titleSpacing: 0,
              //   actions: <Widget>[
              //     IconButton(
              //       icon: Icon(Icons.search),
              //       onPressed: () {
              //         showModalBottomSheet(
              //           context: context,
              //           isScrollControlled: true,
              //           builder: (BuildContext bc) {
              //             return SingleChildScrollView(
              //               child: Container(
              //                 child: Padding(
              //                   padding: EdgeInsets.only(
              //                       bottom: MediaQuery.of(context)
              //                           .viewInsets
              //                           .bottom),
              //                   child: Padding(
              //                     padding: EdgeInsets.all(10),
              //                     child: TextFormField(
              //                       autofocus: true,
              //                       initialValue: search,
              //                       style: TextStyle(fontSize: 20),
              //                       textInputAction: TextInputAction.search,
              //                       onChanged: (String s) {
              //                         search = s;
              //                         context
              //                             .read<DashboardProvider>()
              //                             .filter(keyword: s);
              //                       },
              //                       decoration: loginTextDecoration(
              //                         "Search",
              //                         Icon(Icons.search),
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             );
              //           },
              //         );
              //       },
              //       color: Colors.blue,
              //     ),
              //   ],
              // ),
              // SliverGrid(
              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 3,
              //     childAspectRatio: 2.2,
              //     crossAxisSpacing: 10,
              //   ),
              //   delegate: SliverChildListDelegate(
              // [
              //   SizedBox(
              //     width: double.infinity,
              //     child: FlatButton(
              //       padding: EdgeInsets.symmetric(vertical: 15),
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10)),
              //       color: context.watch<DashboardProvider>().waktu == 1
              //           ? Colors.blue
              //           : Colors.grey,
              //       onPressed: () {
              //         context
              //             .read<DashboardProvider>()
              //             .filter(waktuShow: 1, keyword: "");
              //       },
              //       child:
              //           Text("Hari Ini", style: TextStyle(color: Colors.white)),
              //     ),
              //   ),
              //   SizedBox(
              //     width: double.infinity,
              //     child: FlatButton(
              //       padding: EdgeInsets.symmetric(vertical: 15),
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10)),
              //       color: context.watch<DashboardProvider>().waktu == 2
              //           ? Colors.blue
              //           : Colors.grey,
              //       onPressed: () {
              //         context
              //             .read<DashboardProvider>()
              //             .filter(waktuShow: 2, keyword: "");
              //       },
              //       child: Text("Besok", style: TextStyle(color: Colors.white)),
              //     ),
              //   ),
              //   SizedBox(
              //     width: double.infinity,
              //     child: FlatButton(
              //       padding: EdgeInsets.symmetric(vertical: 15),
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10)),
              //       color: context.watch<DashboardProvider>().waktu == 3
              //           ? Colors.blue
              //           : Colors.grey,
              //       onPressed: () {
              //         context
              //             .read<DashboardProvider>()
              //             .filter(waktuShow: 3, keyword: "");
              //       },
              //       child:
              //           Text("Selesai", style: TextStyle(color: Colors.white)),
              //     ),
              //   ),
              // ],
              //   ),
              // ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    SuratJalanModel curIndex =
                        context.watch<DashboardProvider>().suratJalan[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(R.Router.formRoute, arguments: curIndex)
                              .then((val) => {
                                    context.read<DashboardProvider>().getData()
                                  });
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TitleValueRow(
                                    title: "Bukti Order",
                                    value: curIndex.buktiOrderTrucking),
                                SizedBox(height: 10),
                                TitleValueRow(
                                    title: "Customer",
                                    value: curIndex.namaCustomer),
                                SizedBox(height: 10),
                                TitleValueRow(
                                    title: "Tanggal Ambil",
                                    value: DateFormat(GlobalConfig.formatDate)
                                        .format(curIndex.tanggalAmbil)),
                                // SizedBox(height: 10),
                                // TitleValueRow(
                                //     title: "Pengirim",
                                //     value: curIndex.namaPengirim),
                                // SizedBox(height: 10),
                                // TitleValueRow(
                                //     title: "Penerima",
                                //     value: curIndex.namaPenerima),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount:
                      context.watch<DashboardProvider>().suratJalan.length,
                ),
              ),
            ],
          ),
          // bottomNavigationBar: BottomNavigation(context, 0),
        )
      ]),
      bottomNavigationBar: BottomNavigation(context, 0),
    );
  }
}

class TitleValueRow extends StatelessWidget {
  final String title;
  final String value;

  const TitleValueRow({Key key, this.title, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
