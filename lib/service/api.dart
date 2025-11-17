import 'dart:convert';
import 'dart:developer';
import 'package:absensi_tugas16/constant/endpoint.dart';
import 'package:absensi_tugas16/models/batchmodelpage.dart';
import 'package:absensi_tugas16/models/login_model_page.dart';
import 'package:absensi_tugas16/models/regist_model_page.dart';
import 'package:absensi_tugas16/models/trainingmodel.dart';
import 'package:http/http.dart' as http;

class AuthAPI {
  // =====================================================
  //                   REGISTER USER
  // =====================================================
  static Future<RergisterModel> registerUser({
    required String email,
    required String name,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
    String profilePhoto = "",
  }) async {
    final url = Uri.parse(Endpoint.register);

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhoto,
        "batch_id": batchId,       // <- INT (benar)
        "training_id": trainingId, // <- INT (benar)
      },
    );

    log("REGISTER STATUS: ${response.statusCode}");
    log("REGISTER BODY: ${response.body}");

    final body = json.decode(response.body);

    // SUCCESS
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RergisterModel.fromJson(body);
    }

    // ERROR (422, 500, etc)
    throw Exception(body["message"] ?? "Terjadi kesalahan saat registrasi");
  }


  // =====================================================
  //                   LOGIN USER
  // =====================================================
  static Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {
        "email": email,
        "password": password,
      },
    );

    log("LOGIN STATUS: ${response.statusCode}");
    log("LOGIN BODY: ${response.body}");

    final body = json.decode(response.body);

    // SUCCESS
    if (response.statusCode == 200) {
      return LoginModel.fromJson(body);
    }

    // WRONG CREDENTIALS
    if (response.statusCode == 401 || response.statusCode == 422) {
      throw Exception(body["message"] ?? "Email atau password salah");
    }

    // OTHER ERRORS
    throw Exception("Login gagal, silakan coba lagi.");
  }
}


// =====================================================
//                     TRAINING API
// =====================================================
class TrainingAPI {
  // GET TRAINING
  static Future<List<TrainingModelData>> getTrainings() async {
    final url = Uri.parse(Endpoint.trainings);

    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    log("TRAINING STATUS: ${response.statusCode}");
    log("TRAINING BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List data = jsonBody["data"];
      return data.map((e) => TrainingModelData.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil data training");
  }


  // GET BATCH
  static Future<List<BatchModelData>> getTrainingBatches() async {
    final url = Uri.parse(Endpoint.trainingBatches);

    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    log("BATCH STATUS: ${response.statusCode}");
    log("BATCH BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List data = jsonBody["data"];
      return data.map((e) => BatchModelData.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil data batch");
  }
}
