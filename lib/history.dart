// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, use_key_in_widget_constructors, use_build_context_synchronously, prefer_interpolation_to_compose_strings, deprecated_member_use, unnecessary_this, unused_local_variable, annotate_overrides, prefer_final_fields, non_constant_identifier_names, avoid_unnecessary_containers, sized_box_for_whitespace, must_be_immutable, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppns_smart_pju/global_var.dart' as globals;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dataModel.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

List<DataPJU> dataPJU = [
  DataPJU(
      id: "0",
      segment: "0",
      lokasi: "0",
      prakiraan_cuaca: "0",
      kecerahan: "0",
      tegangan: "0",
      arus: "0",
      daya: "0",
      timestamp: "2000-01-01 00:00:00"),
];
late DataHistory currentData = DataHistory(status: "", pesan: "", data: dataPJU);
DateFormat dateFormatter = new DateFormat("yyyy-MM-dd HH:mm:ss"); 

class History extends StatefulWidget {
  History({super.key, required this.segment, this.restorationId});

  String? restorationId;
  int segment;
  
  @override
  HistoryState createState() => HistoryState();
}

class HistoryState extends State<History> with RestorationMixin  {
  @override
  String? get restorationId => widget.restorationId;
  int? get segment => widget.segment;
  Timer? timer;
  
  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );
@pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(DateTime.now().year-5),
          lastDate: DateTime(DateTime.now().year+5),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(
        //       'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        // ));
      });
      updateValue();
    }
  }

  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);


  @override
  void initState() {
    super.initState();
    getEndpoint();
    timer = Timer.periodic(Duration(milliseconds: 10000), (Timer t) => updateValue());
    setState(() {
      currentData = DataHistory(status: "", pesan: "", data: dataPJU);
    });
  }

  void getEndpoint() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? endpoint = prefs.getString('endpoint');
    if (endpoint != null) {
      setState(() {
        globals.endpoint = endpoint;
      });
    } else {
      globals.endpoint = "0.0.0.0";
    }
  }

  void updateValue() async {
    var url = Uri.parse("http://${globals.endpoint}/api.php?history&segment=${(segment).toString()}&date=${DateFormat('yyyy-MM-dd').format(_selectedDate.value)}");
    print(url);
    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return http.Response('Error', 408);
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        var respon = Json.tryDecode(response.body);
        if (this.mounted) {
          setState(() {
            currentData = DataHistory.fromJson(Json.tryDecode(response.body));
          });
        }
        print(dateFormatter.parse(currentData.data[0].timestamp));
      }
    } on Exception catch (_) {}
  }
  
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        timer?.cancel();
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
          body: Center(
        child: Container(
          child: Column(children: [
          // SfDateRangePicker(),
          OutlinedButton(
            onPressed: () {
              _restorableDatePickerRouteFuture.present();
            },
            child: Text(DateFormat('dd MMMM yyyy').format(_selectedDate.value)),
          ),
          SfCartesianChart(
            primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat("HH:mm:ss"),
            ),
            title: ChartTitle(text: 'History Chart'),
            legend: Legend(isVisible: true),
            series: getDefaultData(),
            tooltipBehavior: _tooltipBehavior,
          ),
          ],)
        )
      ),
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            backgroundColor: Color.fromARGB(255, 0, 44, 138),
            title: Text(
              "History (Segment ${segment.toString()})",
              style: TextStyle(color: Colors.white),
            ), 
          )
      )         
    );
  }
}
class SalesData {
  SalesData(this.date, this.country, this.y, this.y1, this.y2, this.y3, this.y4);
  final DateTime date;
  final String country;
  final double y;
  final double y1;
  final double y2;
  final double y3;
  final double y4;
}

List<CartesianSeries<DataPJU, DateTime>> getDefaultData() {
  final bool isDataLabelVisible = false,
      isMarkerVisible = true,
      isTooltipVisible = true;
  double? lineWidth, markerWidth, markerHeight;
  final List<SalesData> chartData = <SalesData>[
    SalesData(DateTime(2024, 4, 12, 20, 20, 00), 'India', 1.5, 21, 28, 680, 760),
    SalesData(DateTime(2024, 4, 12, 20, 20, 01), 'China', 2.2, 24, 44, 550, 880),
    SalesData(DateTime(2024, 4, 12, 20, 20, 02), 'USA', 3.32, 36, 48, 440, 788),
    SalesData(DateTime(2024, 4, 12, 20, 20, 03), 'Japan', 4.56, 38, 50, 350, 560),
    SalesData(DateTime(2024, 4, 12, 20, 20, 04), 'Russia', 5.87, 54, 66, 444, 566),
    SalesData(DateTime(2024, 4, 12, 20, 20, 05), 'France', 6.8, 57, 78, 780, 650),
    SalesData(DateTime(2024, 4, 12, 20, 20, 06), 'Germany', 8.5, 70, 84, 450, 800),
  ];
  return <LineSeries<DataPJU, DateTime>>[
    LineSeries<DataPJU, DateTime>(
        name: "Tegangan",
        enableTooltip: true,
        dataSource: currentData.data,
        xValueMapper: (DataPJU history, _) => dateFormatter.parse(history.timestamp),
        yValueMapper: (DataPJU history, _) => double.parse(history.tegangan),
        width: lineWidth ?? 2,
        markerSettings: MarkerSettings(
            isVisible: isMarkerVisible,
            height: markerWidth ?? 4,
            width: markerHeight ?? 4,
            shape: DataMarkerType.circle,
            borderWidth: 3,
            borderColor: Colors.black),
        dataLabelSettings: DataLabelSettings(
            isVisible: isDataLabelVisible,
            labelAlignment: ChartDataLabelAlignment.auto)),
    LineSeries<DataPJU, DateTime>(
        name: "Arus",
        enableTooltip: true,
        dataSource: currentData.data,
        xValueMapper: (DataPJU history, _) => dateFormatter.parse(history.timestamp),
        yValueMapper: (DataPJU history, _) => double.parse(history.arus),
        width: lineWidth ?? 2,
        markerSettings: MarkerSettings(
            isVisible: isMarkerVisible,
            height: markerWidth ?? 4,
            width: markerHeight ?? 4,
            shape: DataMarkerType.circle,
            borderWidth: 3,
            borderColor: Colors.black),
        dataLabelSettings: DataLabelSettings(
            isVisible: isDataLabelVisible,
            labelAlignment: ChartDataLabelAlignment.auto)),
    LineSeries<DataPJU, DateTime>(
        name: "Daya",
        enableTooltip: true,
        dataSource: currentData.data,
        xValueMapper: (DataPJU history, _) => dateFormatter.parse(history.timestamp),
        yValueMapper: (DataPJU history, _) => double.parse(history.daya),
        width: lineWidth ?? 2,
        markerSettings: MarkerSettings(
            isVisible: isMarkerVisible,
            height: markerWidth ?? 4,
            width: markerHeight ?? 4,
            shape: DataMarkerType.circle,
            borderWidth: 3,
            borderColor: Colors.black),
        dataLabelSettings: DataLabelSettings(
            isVisible: isDataLabelVisible,
            labelAlignment: ChartDataLabelAlignment.auto)),
    LineSeries<DataPJU, DateTime>(
        name: "Kecerahan",
        enableTooltip: true,
        dataSource: currentData.data,
        xValueMapper: (DataPJU history, _) => dateFormatter.parse(history.timestamp),
        yValueMapper: (DataPJU history, _) => double.parse(history.kecerahan),
        width: lineWidth ?? 2,
        markerSettings: MarkerSettings(
            isVisible: isMarkerVisible,
            height: markerWidth ?? 4,
            width: markerHeight ?? 4,
            shape: DataMarkerType.circle,
            borderWidth: 3,
            borderColor: Colors.black),
        dataLabelSettings: DataLabelSettings(
            isVisible: isDataLabelVisible,
            labelAlignment: ChartDataLabelAlignment.auto)),

  ];
}


// class DatePickerExample extends StatefulWidget {
//   const DatePickerExample({super.key, this.restorationId});

//   final String? restorationId;

//   @override
//   State<DatePickerExample> createState() => _DatePickerExampleState();
// }

// /// RestorationProperty objects can be used because of RestorationMixin.
// class _DatePickerExampleState extends State<DatePickerExample> with RestorationMixin {
//   // In this example, the restoration ID for the mixin is passed in through
//   // the [StatefulWidget]'s constructor.
//   @override
//   String? get restorationId => widget.restorationId;

//   final RestorableDateTime _selectedDate =
//       RestorableDateTime(DateTime(2021, 7, 25));
//   late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
//       RestorableRouteFuture<DateTime?>(
//     onComplete: _selectDate,
//     onPresent: (NavigatorState navigator, Object? arguments) {
//       return navigator.restorablePush(
//         _datePickerRoute,
//         arguments: _selectedDate.value.millisecondsSinceEpoch,
//       );
//     },
//   );

//   @pragma('vm:entry-point')
//   static Route<DateTime> _datePickerRoute(
//     BuildContext context,
//     Object? arguments,
//   ) {
//     return DialogRoute<DateTime>(
//       context: context,
//       builder: (BuildContext context) {
//         return DatePickerDialog(
//           restorationId: 'date_picker_dialog',
//           initialEntryMode: DatePickerEntryMode.calendarOnly,
//           initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
//           firstDate: DateTime(2021),
//           lastDate: DateTime(2022),
//         );
//       },
//     );
//   }

//   @override
//   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
//     registerForRestoration(_selectedDate, 'selected_date');
//     registerForRestoration(
//         _restorableDatePickerRouteFuture, 'date_picker_route_future');
//   }

//   void _selectDate(DateTime? newSelectedDate) {
//     if (newSelectedDate != null) {
//       setState(() {
//         _selectedDate.value = newSelectedDate;
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(
//               'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
//         ));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: OutlinedButton(
//           onPressed: () {
//             _restorableDatePickerRouteFuture.present();
//           },
//           child: Text('${_selectedDate.value}'),
//         ),
//       ),
//     );
//   }
// }