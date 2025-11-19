import 'dart:convert';
import 'package:absensi_tugas16/constant/endpoint.dart';
import 'package:absensi_tugas16/preference/preference_handler.dart';
import 'package:http/http.dart' as http;

class AbsensiAPI {
  // ============================================================
  // BASE REQUEST
  // ============================================================
  static Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    final token = await PreferenceHandler.getToken();
    final res = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> _get(String endpoint) async {
    final token = await PreferenceHandler.getToken();
    final res = await http.get(
      Uri.parse(endpoint),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> _put(String endpoint, Map<String, dynamic> body) async {
    final token = await PreferenceHandler.getToken();
    final res = await http.put(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> _delete(String endpoint) async {
    final token = await PreferenceHandler.getToken();
    final res = await http.delete(
      Uri.parse(endpoint),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  // ============================================================
  // ABSEN CHECK IN
  // ============================================================
  static Future<dynamic> checkIn({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) {
    return _post(Endpoint.checkIn, {
      "attendance_date": attendanceDate,
      "check_in": time,
      "check_in_lat": lat,
      "check_in_lng": lng,
      "check_in_address": address,
      "status": "masuk",
    });
  }

  // ============================================================
  // ABSEN CHECK OUT
  // ============================================================
  static Future<dynamic> checkOut({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) {
    return _post(Endpoint.checkOut, {
      "attendance_date": attendanceDate,
      "check_out": time,
      "check_out_lat": lat,
      "check_out_lng": lng,
      "check_out_address": address,
      "check_out_location": "$lat,$lng",
    });
  }

  // ============================================================
  // IZIN
  // ============================================================
  static Future<dynamic> izin({
    required String date,
    required String alasan,
  }) {
    return _post(Endpoint.izin, {
      "date": date,
      "alasan_izin": alasan,
    });
  }

  // ============================================================
  // HISTORY ABSENSI
  // ============================================================
  static Future<dynamic> getHistory() {
    return _get(Endpoint.history);
  }

  // ============================================================
  // DELETE ABSEN
  // ============================================================
  static Future<dynamic> deleteAbsen(int id) {
    return _delete("${Endpoint.deleteAbsen}/$id");
  }

  // ============================================================
  // STATISTIK
  // ============================================================
  static Future<dynamic> getStatistik() {
    return _get(Endpoint.statistik);
  }

  // ============================================================
  // PROFILE GET
  // ============================================================
  static Future<dynamic> getProfile() {
    return _get(Endpoint.profile);
  }

  // ============================================================
  // PROFILE UPDATE
  // ============================================================
  static Future<dynamic> editProfile({
  required String name,
}) {
  return _put(Endpoint.updateProfile, {
    "name": name,
  });
}

// DELETE ABSEN
  static Future<void> deleteAbsenById(int id) async {
    await _delete("${Endpoint.deleteAbsen}/$id");
  }
}
