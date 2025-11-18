import 'dart:convert';
import 'package:absensi_tugas16/preference/preference_handler.dart';
import 'package:http/http.dart' as http;

class AbsensiAPI {
  static const baseUrl = "https://appabsensi.mobileprojp.com/api";

  // ===========================================================
  // BASE REQUEST HANDLER
  // ===========================================================
  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("URL POST = $baseUrl$endpoint");
    print("BODY     = $body");
    print("RESP     = ${response.body}");

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> _get(String endpoint) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> _put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> _delete(String endpoint) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(response.body);
  }

  // ===========================================================
  // ABSENSI — CHECK IN
  // ===========================================================

  static Future<dynamic> checkIn({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) {
    return _post("/absen/check-in", {
      "attendance_date": attendanceDate,
      "check_in": time,
      "check_in_lat": lat,
      "check_in_lng": lng,
      "check_in_address": address,
      "status": "masuk",
    });
  }

  // ===========================================================
  // ABSENSI — CHECK OUT
  // ===========================================================

  static Future<dynamic> checkOut({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) {
    return _post("/absen/check-out", {
      "attendance_date": attendanceDate,
      "check_out": time,
      "check_out_lat": lat,
      "check_out_lng": lng,
      "check_out_address": address,
      "check_out_location": "$lat,$lng",
    });
  }

  // ===========================================================
  // ABSENSI — IZIN
  // ===========================================================

  static Future<dynamic> izin({required String date, required String alasan}) {
    return _post("/absen-izin", {"date": date, "alasan_izin": alasan});
  }

  // ===========================================================
  // ABSENSI — HISTORY
  // ===========================================================

  static Future<dynamic> getHistory() {
    return _get("/history-absen");
  }

  // ===========================================================
  // ABSENSI — DELETE HISTORY (Opsional)
  // ===========================================================

  static Future<dynamic> deleteAbsen(int id) {
    return _delete("/delete-absen?id=$id");
  }

  // ===========================================================
  // ABSENSI — STATISTIK
  // ===========================================================
  // Response:
  // {
  //   "message": "Statistik absensi pengguna",
  //   "data": {
  //      "total_absen": 5,
  //      "total_masuk": 5,
  //      "total_izin": 0,
  //      "sudah_absen_hari_ini": false
  //   }
  // }

  static Future<dynamic> getStatistik() {
    return _get("/absen/stats");
  }

  // ===========================================================
  // PROFILE
  // ===========================================================

  static Future<dynamic> getProfile() {
    return _get("/profile");
  }

  static Future<dynamic> editProfile({
    required String name,
    required String email,
  }) {
    return _put("/edit-profile", {"name": name, "email": email});
  }
}
