import 'package:absensi_tugas16/preference/preference_handler.dart';
import 'package:absensi_tugas16/service/absensiapi.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class DashboardYellow extends StatefulWidget {
  const DashboardYellow({super.key});

  @override
  State<DashboardYellow> createState() => _DashboardYellowState();
}

class _DashboardYellowState extends State<DashboardYellow> {
  String name = "";
  String today = "";
  String greeting = "";

  Position? currentPos;
  String currentAddress = "-";

  bool isLoadingCheckIn = false;
  bool isLoadingCheckOut = false;

  // statistik
  int totalAbsen = 0;
  int totalMasuk = 0;
  int totalIzin = 0;
  bool sudahAbsenHariIni = false;

  @override
  void initState() {
    super.initState();
    initUser();
    getGreeting();
    formatToday();
    loadStatistik();
  }

  // =====================================================================
  // Ambil nama user dari SharedPreferences
  // =====================================================================
  Future<void> initUser() async {
    final savedName = await PreferenceHandler.getName();
    setState(() => name = savedName ?? "User");
  }

  void getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12)
      greeting = "Selamat Pagi 🌞";
    else if (hour < 17)
      greeting = "Selamat Siang 🌤️";
    else
      greeting = "Selamat Malam 🌙";
  }

  void formatToday() {
    today = DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(DateTime.now());
  }

  // =====================================================================
  // Memuat Statistik
  // =====================================================================
  Future<void> loadStatistik() async {
    try {
      final res = await AbsensiAPI.getStatistik();
      print("=== STATISTIK RESPONSE ===");
      print(res);
      final data = res["data"];
      print(data);

      setState(() {
        totalAbsen = data["total_absen"];
        totalMasuk = data["total_masuk"];
        totalIzin = data["total_izin"];
        sudahAbsenHariIni = data["sudah_absen_hari_ini"];
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Gagal memuat statistik $e");
    }
  }

  // =====================================================================
  // Ambil Lokasi GPS
  // =====================================================================
  Future<bool> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Nyalakan GPS terlebih dahulu");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Izin lokasi ditolak permanen");
      return false;
    }

    try {
      currentPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await getAddressFromLatLng();
      setState(() {});
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal mengambil lokasi");
      return false;
    }
  }

  // =====================================================================
  // Ambil alamat dari koordinat
  // =====================================================================
  Future<void> getAddressFromLatLng() async {
    if (currentPos == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPos!.latitude,
        currentPos!.longitude,
      );

      final p = placemarks.first;

      setState(() {
        currentAddress =
            "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal mengambil alamat");
    }
  }

  // =====================================================================
  // CHECK IN
  // =====================================================================
  Future<void> checkIn() async {
    setState(() => isLoadingCheckIn = true);

    final ok = await getLocation();
    if (!ok) {
      setState(() => isLoadingCheckIn = false);
      return;
    }

    try {
      final response = await AbsensiAPI.checkIn(
        attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: DateFormat('HH:mm').format(DateTime.now()),
        lat: currentPos!.latitude,
        lng: currentPos!.longitude,
        address: currentAddress,
      );

      print(response);

      Fluttertoast.showToast(msg: "Absen Masuk Berhasil 🍋");
      loadStatistik();
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal Absen: $e");
    }

    setState(() => isLoadingCheckIn = false);
  }

  // =====================================================================
  // CHECK OUT
  // =====================================================================
  Future<void> checkOut() async {
    setState(() => isLoadingCheckOut = true);

    final ok = await getLocation();
    if (!ok) {
      setState(() => isLoadingCheckOut = false);
      return;
    }

    try {
      await AbsensiAPI.checkOut(
        attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: DateFormat('HH:mm').format(DateTime.now()),
        lat: currentPos!.latitude,
        lng: currentPos!.longitude,
        address: currentAddress,
      );

      Fluttertoast.showToast(msg: "Absen Pulang Berhasil 🌙");
      loadStatistik();
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal Absen: $e");
    }

    setState(() => isLoadingCheckOut = false);
  }

  // =====================================================================
  // Google Maps Widget
  // =====================================================================
  Widget buildMapBox() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: currentPos == null
          ? Center(
              child: ElevatedButton(
                onPressed: () async => await getLocation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Ambil Lokasi 📍",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentPos!.latitude, currentPos!.longitude),
                  zoom: 16,
                ),
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                markers: {
                  Marker(
                    markerId: const MarkerId("posisi_saya"),
                    position: LatLng(
                      currentPos!.latitude,
                      currentPos!.longitude,
                    ),
                    infoWindow: InfoWindow(title: currentAddress),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
    );
  }

  // =====================================================================
  // UI
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              ),
              Text(
                "Halo, $name 👋",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.brown.shade800,
                ),
              ),
              Text(today, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: checkInButton()),
                  const SizedBox(width: 16),
                  Expanded(child: checkOutButton()),
                ],
              ),

              const SizedBox(height: 26),

              Text(
                "Alamat Saat Ini:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              ),
              Text(
                currentAddress,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              buildMapBox(),
              const SizedBox(height: 26),

              buildStatisticCard(),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // BUTTON UI
  // =====================================================================
  Widget checkInButton() {
    return ElevatedButton(
      onPressed: isLoadingCheckIn ? null : checkIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade400,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoadingCheckIn
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Absen Masuk",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget checkOutButton() {
    return ElevatedButton(
      onPressed: isLoadingCheckOut ? null : checkOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown.shade400,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoadingCheckOut
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Absen Pulang",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }

  // =====================================================================
  // STATISTIK LUCU
  // =====================================================================
  Widget buildStatisticCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Statistik Absensi Kamu 🍋✨",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF6B4F4F),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // HADIR
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "✨ Hadir",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$totalMasuk",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // IZIN
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "📄 Izin",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$totalIzin",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 30,
                color: Colors.blue,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Absen",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "$totalAbsen hari",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: sudahAbsenHariIni
                ? Colors.green.shade100
                : Colors.red.shade100,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(
                sudahAbsenHariIni
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 36,
                color: sudahAbsenHariIni ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sudahAbsenHariIni
                        ? "Kamu sudah absen hari ini! 🎉"
                        : "Belum absen hari ini 😢",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: sudahAbsenHariIni
                          ? Colors.green.shade800
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sudahAbsenHariIni
                        ? "Tetap semangat ya 🍋💛"
                        : "Jangan lupa absen ya 🍋",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
