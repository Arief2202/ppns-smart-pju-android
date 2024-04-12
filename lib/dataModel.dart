// ignore_for_file: camel_case_types, unnecessary_null_comparison, file_names, non_constant_identifier_names
import 'dart:convert';

class FromAPI {
  FromAPI({
    required this.status,
    required this.pesan,
    required this.data,
    required this.kecerahan_lampu,
  });
  String status;
  String pesan;
  List<DataPJU> data;
  List<DataKecerahan>?kecerahan_lampu;
  
  factory FromAPI.fromJson(Map<String, dynamic> json) => FromAPI(
    status: json["status"],
    pesan: json["pesan"],
    data: List<DataPJU>.from((json["data"] as List).map((x) => DataPJU.fromJson(x)).where((content) => content.segment != null)),
    kecerahan_lampu: List<DataKecerahan>.from((json["kecerahan_lampu"] as List).map((x) => DataKecerahan.fromJson(x)).where((content) => content.segment != null)),
  );
}

class DataHistory{
  DataHistory({
    required this.status,
    required this.pesan,
    required this.data
  });
  String status;
  String pesan;
  List<DataPJU> data;

  factory DataHistory.fromJson(Map<String, dynamic> json) => DataHistory(
    status: json["status"],
    pesan: json["pesan"],
    data: List<DataPJU>.from((json["data"] as List).map((x) => DataPJU.fromJson(x)).where((content) => content.segment != null)),
  );
}

class DataPJU {
  DataPJU({
    required this.id,
    required this.segment,
    required this.lokasi,
    required this.prakiraan_cuaca,
    required this.kecerahan,
    required this.tegangan,
    required this.arus,
    required this.daya,
    required this.timestamp,
  });
  String id;
  String segment;
  String lokasi;
  String prakiraan_cuaca;
  String kecerahan;
  String tegangan;
  String arus;
  String daya;
  String timestamp;
  
  factory DataPJU.fromJson(Map<String, dynamic> json) => DataPJU(
    id: json["id"],
    segment: json["segment"],
    lokasi: json["lokasi"],
    prakiraan_cuaca: json["prakiraan_cuaca"],
    kecerahan: json["kecerahan"],
    tegangan: json["tegangan"],
    arus: json["arus"],
    daya: json["daya"],
    timestamp: json["timestamp"],
  );
}


class DataKecerahan {
  DataKecerahan({
    required this.id,
    required this.segment,
    required this.kecerahan_lampu,
    required this.updated_at,
  });
  String id;
  String segment;
  String kecerahan_lampu;
  String updated_at;
  factory DataKecerahan.fromJson(Map<String, dynamic> json) => DataKecerahan(
    id: json["id"],
    segment: json["segment"],
    kecerahan_lampu: json["kecerahan_lampu"],
    updated_at: json["updated_at"],
  );
}

class Json {
  static String? tryEncode(data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return null;
    }
  }

  static dynamic tryDecode(data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

}