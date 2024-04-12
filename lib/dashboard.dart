// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, use_key_in_widget_constructors, use_build_context_synchronously, prefer_interpolation_to_compose_strings, deprecated_member_use, unnecessary_this, unused_local_variable, annotate_overrides, prefer_final_fields, non_constant_identifier_names, avoid_unnecessary_containers, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:ppns_smart_pju/global_var.dart' as globals;
import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dataModel.dart';
import 'history.dart';

class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  List<TextEditingController> _data = [TextEditingController()];
  bool status = false;
  Timer? timer;
  double Metana = 0;
  double CO = 0;
  int _selectedIndex = 0;
  double _currentSliderValue = 20;
  List<DataPJU> dataPJU = [
    DataPJU(
        id: "1",
        segment: "1",
        lokasi: "",
        prakiraan_cuaca: "",
        kecerahan: "",
        tegangan: "",
        arus: "",
        daya: "",
        timestamp: ""),
    DataPJU(
        id: "2",
        segment: "2",
        lokasi: "",
        prakiraan_cuaca: "",
        kecerahan: "",
        tegangan: "",
        arus: "",
        daya: "",
        timestamp: ""),
    DataPJU(
        id: "3",
        segment: "3",
        lokasi: "",
        prakiraan_cuaca: "",
        kecerahan: "",
        tegangan: "",
        arus: "",
        daya: "",
        timestamp: ""),
    DataPJU(
        id: "4",
        segment: "4",
        lokasi: "",
        prakiraan_cuaca: "",
        kecerahan: "",
        tegangan: "",
        arus: "",
        daya: "",
        timestamp: ""),
  ];
  List<DataKecerahan> dataKecerahan = [
    DataKecerahan(id: "1", segment: "1", kecerahan_lampu: "0", updated_at: ""),
    DataKecerahan(id: "2", segment: "2", kecerahan_lampu: "0", updated_at: ""),
    DataKecerahan(id: "3", segment: "3", kecerahan_lampu: "0", updated_at: ""),
    DataKecerahan(id: "4", segment: "4", kecerahan_lampu: "0", updated_at: ""),
  ];
  late FromAPI currentData = FromAPI(
      status: "", pesan: "", data: dataPJU, kecerahan_lampu: dataKecerahan);

  void initState() {
    super.initState();
    getEndpoint();
    timer = Timer.periodic(
        Duration(milliseconds: 1000), (Timer t) => updateValue());
    setState(() {
      _currentSliderValue = double.parse(
          currentData.kecerahan_lampu![_selectedIndex].kecerahan_lampu);
    });
  }

  void getEndpoint() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? endpoint = prefs.getString('endpoint');
    if (endpoint != null) {
      setState(() {
        _data[0].text = endpoint;
        globals.endpoint = endpoint;
      });
    } else {
      _data[0].text = "0.0.0.0";
      globals.endpoint = "0.0.0.0";
    }
  }

  void updateValue() async {
    var url = Uri.parse("http://${globals.endpoint}/api.php");
    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          return http.Response('Error', 408);
        },
      );
      if (response.statusCode == 200) {
        var respon = Json.tryDecode(response.body);
        if (this.mounted) {
          setState(() {
            currentData = FromAPI.fromJson(Json.tryDecode(response.body));
            _currentSliderValue = double.parse(
                currentData.kecerahan_lampu![_selectedIndex].kecerahan_lampu);
          });
        }
      }
    } on Exception catch (_) {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentSliderValue = double.parse(
          currentData.kecerahan_lampu![_selectedIndex].kecerahan_lampu);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        timer?.cancel();
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 0, 44, 138),
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back),
            //   onPressed: () => Phoenix.rebirth(context),
            // ),
            title: Text(
              "Segment ${currentData.data[_selectedIndex].segment}",
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.settings,
                      color: Colors.white, size: 20.0),
                  onPressed: () async {
                    //================================ ALERT UNTUK SETTING API ========================================
                    Alert(
                      context: context,
                      // type: AlertType.info,
                      desc: "Setting API",
                      content: Column(
                        children: <Widget>[
                          SizedBox(
                              height: MediaQuery.of(context).size.width / 15),
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'IP Endpoint',
                              labelStyle: TextStyle(fontSize: 20),
                            ),
                            controller: _data[0],
                          ),
                        ],
                      ),
                      buttons: [
                        DialogButton(
                            child: Text(
                              "Save",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () async {
                              if (_data[0].text.isEmpty) {
                                status = false;
                                Alert(
                                  context: context,
                                  type: AlertType.error,
                                  title: "Value Cannot be Empty!",
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                ).show();
                              } else {
                                var url = Uri.parse('http://' +
                                    _data[0].text +
                                    '/checkConnection.php');
                                try {
                                  final response = await http.get(url).timeout(
                                    const Duration(
                                        seconds: globals.httpTimeout),
                                    onTimeout: () {
                                      // Time has run out, do what you wanted to do.
                                      return http.Response('Error',
                                          408); // Request Timeout response status code
                                    },
                                  );
                                  // context.loaderOverlay.hide();
                                  if (response.statusCode == 200) {
                                    Alert(
                                      context: context,
                                      type: AlertType.success,
                                      title: "Connection OK",
                                      buttons: [
                                        DialogButton(
                                            child: Text(
                                              "OK",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                            onPressed: () async {
                                              final SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              setState(() {
                                                globals.endpoint =
                                                    _data[0].text;
                                                prefs.setString(
                                                    "endpoint", _data[0].text);
                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            })
                                      ],
                                    ).show();
                                  } else {
                                    Alert(
                                      context: context,
                                      type: AlertType.error,
                                      title: "Connection Failed!",
                                      desc: "Please check Endpoint IP",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        )
                                      ],
                                    ).show();
                                  }
                                } on Exception catch (_) {
                                  Alert(
                                    context: context,
                                    type: AlertType.error,
                                    title: "Connection Failed!",
                                    desc: "Please check Endpoint IP",
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      )
                                    ],
                                  ).show();
                                  // rethrow;
                                }
                              }
                            }),
                      ],
                    ).show();

                    //================================ END ALERT UNTUK SETTING API ========================================
                  })
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: true,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Colors.black,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.data_thresholding),
                label: 'Segment 1',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.data_thresholding),
                label: 'Segment 2',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.data_thresholding),
                label: 'Segment 3',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.data_thresholding),
                label: 'Segment 4',
              ),
            ],
          ),
          body: StaggeredGridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: <Widget>[
              myCard("Lokasi PJU", currentData.data[_selectedIndex].lokasi,
                  Icon(Icons.location_on, color: Colors.white, size: 20.0)),
              myCard(
                  "Prakiraan Cuaca",
                  currentData.data[_selectedIndex].prakiraan_cuaca,
                  Icon(Icons.cloud, color: Colors.white, size: 20.0)),
              myCard("Kecerahan", currentData.data[_selectedIndex].kecerahan,
                  Icon(Icons.light, color: Colors.white, size: 20.0)),
              myCard("Tegangan", currentData.data[_selectedIndex].tegangan,
                  Icon(Icons.bolt, color: Colors.white, size: 20.0)),
              myCard("Arus", currentData.data[_selectedIndex].arus,
                  Icon(Icons.bolt, color: Colors.white, size: 20.0)),
              myCard("Daya", currentData.data[_selectedIndex].daya,
                  Icon(Icons.bolt, color: Colors.white, size: 20.0)),
              myCardSlider("Kecerahan Lampu", "value",
                  Icon(Icons.light, color: Colors.white, size: 20.0)),
              myCardButton("Kecerahan Lampu", "value",
                  Icon(Icons.light, color: Colors.white, size: 20.0)),
            ],
            staggeredTiles: [
              StaggeredTile.extent(2, 80.0),
              StaggeredTile.extent(2, 80.0),
              StaggeredTile.extent(1, 80.0),
              StaggeredTile.extent(1, 80.0),
              StaggeredTile.extent(1, 80.0),
              StaggeredTile.extent(1, 80.0),
              StaggeredTile.extent(2, 100.0),
              StaggeredTile.extent(2, 90.0),
            ],
          )),
    );
  }

  Widget _buildTile(Widget child, {Function()? onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Color(0x802196F3),
        child: InkWell(
            // Do onTap() if it isn't null, otherwise do print()
            onTap: onTap != null
                ? () => onTap()
                : () {
                    print('Not set yet');
                  },
            child: child));
  }

  Widget myCard(String title, String value, Widget icon) {
    return _buildTile(
      Padding(
        padding:
            const EdgeInsets.only(left: 24.0, right: 24, bottom: 15, top: 15),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Container(
                  //   width:100,
                  //   child:
                  //     Flexible(
                  //         child: new Text(
                  //           title,
                  //         style: TextStyle(color: Colors.blueAccent))

                  //     ),
                  // ),
                  Text(title, style: TextStyle(color: Colors.blueAccent)),
                  Text(value,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0))
                ],
              ),
              Container(
                  // padding: EdgeInsets.only(top: 16),
                  child: Material(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24.0),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: icon,
                      ))))
            ]),
      ),
    );
  }

  Widget myCardSlider(String title, String value, Widget icon) {
    return _buildTile(
      Padding(
        padding:
            const EdgeInsets.only(left: 24.0, right: 24, bottom: 15, top: 15),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: TextStyle(color: Colors.blueAccent)),
                    Container(
                      width: MediaQuery.of(context).size.width - 150,
                      child: Slider(
                        value: _currentSliderValue,
                        max: 100,
                        divisions: 10,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) async {
                          setState(() {
                            _currentSliderValue = value;
                          });

                          var url =
                              Uri.parse("http://${globals.endpoint}/api.php");
                          try {
                            final response = await http.post(url, body: {
                              'updateKecerahanLampu': '1',
                              'segment': (_selectedIndex + 1).toString(),
                              'value': value.toString()
                            }).timeout(
                              const Duration(seconds: 1),
                              onTimeout: () {
                                return http.Response('Error', 408);
                              },
                            );
                            if (response.statusCode == 200) {}
                          } on Exception catch (_) {}
                        },
                      ),
                    ),
                  ]),
              Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Material(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24.0),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: icon,
                      ))))
            ]),
      ),
    );
  }

  Widget myCardButton(String title, String value, Widget icon) {
    return _buildTile(
      Padding(
        padding:
            const EdgeInsets.only(left: 24.0, right: 24, bottom: 24, top: 14),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      height: 50,
                      child: ElevatedButton(
                          child: Text("History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return History(segment: _selectedIndex+1);
                              }),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                          )
                      ),
                    ),
                  ])
            ]),
      ),
    );
  }
}
