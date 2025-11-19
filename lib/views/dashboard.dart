import 'dart:async';
import 'package:absensi_tugas16/models/presence_history_model.dart';
import 'package:absensi_tugas16/preference/preference_handler.dart';
import 'package:absensi_tugas16/service/absensiapi.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class DashboardYellowFinal extends StatefulWidget {
  const DashboardYellowFinal({super.key});

  @override
  State<DashboardYellowFinal> createState() => _DashboardYellowFinalState();
}

class _DashboardYellowFinalState extends State<DashboardYellowFinal> {
  // ===================== USER DATA =====================
  String name = "";
  String today = "";
  String greeting = "";

  // CLOCK
  String currentTime = "";
  Timer? clockTimer;

  // LOKASI
  Position? currentPos;
  String currentAddress = "-";

  // STATISTIK
  int totalAbsen = 0;
  int totalMasuk = 0;
  int totalIzin = 0;
  bool sudahAbsenHariIni = false;

  // HISTORY
  bool loadingHistory = true;
  List<Presence> history = [];

  @override
  void initState() {
    super.initState();
    initUser();
    getGreeting();
    formatToday();
    startClock();
    loadStatistik();
    loadHistory();
    getLocation();
  }

  @override
  void dispose() {
    clockTimer?.cancel();
    super.dispose();
  }

  // ===================== CLOCK =====================
  void startClock() {
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateFormat("HH:mm:ss").format(DateTime.now());
      });
    });
  }

  // ===================== USER =====================
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

  // ===================== STATISTIK =====================
  Future<void> loadStatistik() async {
    try {
      final res = await AbsensiAPI.getStatistik();
      final data = res["data"];

      setState(() {
        totalAbsen = data["total_absen"];
        totalMasuk = data["total_masuk"];
        totalIzin = data["total_izin"];
        sudahAbsenHariIni = data["sudah_absen_hari_ini"];
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat statistik");
    }
  }

  // ===================== HISTORY =====================
  Future<void> loadHistory() async {
    setState(() => loadingHistory = true);

    try {
      final res = await AbsensiAPI.getHistory();
      final model = PresenceHistoryModel.fromJson(res);

      setState(() => history = model.data);
    } catch (e) {
      debugPrint("Error load history: $e");
    }

    setState(() => loadingHistory = false);
  }

  // ===================== DELETE HISTORY =====================
  Future<void> _deleteHistory(int? id) async {
    if (id == null) return;

    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text("Hapus Riwayat?"),
          content: const Text(
            "Riwayat absensi ini akan dihapus permanen dan tidak bisa dikembalikan.",
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(c),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hapus"),
              onPressed: () async {
                Navigator.pop(c);

                try {
                  await AbsensiAPI.deleteAbsen(id);
                  Fluttertoast.showToast(msg: "Riwayat berhasil dihapus");

                  await loadHistory();
                  setState(() {});
                } catch (e) {
                  Fluttertoast.showToast(msg: "Gagal menghapus riwayat");
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ===================== GET LOCATION =====================
  Future<void> getLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;

      currentPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> p = await placemarkFromCoordinates(
        currentPos!.latitude,
        currentPos!.longitude,
      );

      final place = p.first;

      setState(() {
        currentAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
      });
    } catch (_) {}
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D1),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await loadStatistik();
            await loadHistory();
            await getLocation();
          },
          color: Colors.orange,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                _buildLocation(),
                const SizedBox(height: 22),

                _buildStatistik(),
                const SizedBox(height: 22),

                _buildStatusHariIni(),
                const SizedBox(height: 26),

                const Text(
                  "Riwayat Absensi Terakhir",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B4F4F),
                  ),
                ),
                const SizedBox(height: 12),

                if (loadingHistory)
                  const Center(child: CircularProgressIndicator())
                else if (history.isEmpty)
                  _buildEmptyHistory()
                else
                  Column(
                    children: history
                        .take(5)
                        .map((p) => _buildHistoryCard(p))
                        .toList(),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== HEADER UI =====================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD88A), Color(0xFFFFF0C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B4F4F),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Halo, $name 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4B2E2E),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  today,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B4F4F),
                  ),
                ),
                const SizedBox(height: 8),

                // CLOCK
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sunny_snowing,
              color: Colors.orange,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== LOCATION =====================
  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Lokasi Kamu Sekarang",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.brown.shade700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),

        Text(
          currentAddress,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 10),

        _buildMapCard(),
      ],
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 210,
          child: currentPos == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentPos!.latitude, currentPos!.longitude),
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                ),
        ),
      ),
    );
  }

  // ===================== STATISTIK =====================
  Widget _buildStatistik() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Statistik Absensi 🍋✨",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6B4F4F),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            _statCard("Hadir", "$totalMasuk", Colors.green),
            _statCard("Izin", "$totalIzin", Colors.orange),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Colors.blue,
                size: 30,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Absen",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    "$totalAbsen hari",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== STATUS HARI INI =====================
  Widget _buildStatusHariIni() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: sudahAbsenHariIni ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          Icon(
            sudahAbsenHariIni
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 40,
            color: sudahAbsenHariIni ? Colors.green : Colors.red,
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sudahAbsenHariIni
                    ? "Kamu sudah absen hari ini 🎉"
                    : "Belum absen hari ini 😢",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: sudahAbsenHariIni
                      ? Colors.green.shade800
                      : Colors.red.shade700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                sudahAbsenHariIni
                    ? "Tetap semangat & jaga performa ya 🍋💛"
                    : "Jangan lupa absen supaya datanya rapi ✨",
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== EMPTY HISTORY =====================
  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(Icons.history, size: 32, color: Colors.orange.shade300),
          const SizedBox(width: 12),
          const Text("Belum ada riwayat absensi"),
        ],
      ),
    );
  }

  // ===================== HISTORY ITEM (SOFT PASTEL VERSION) =====================
  Widget _buildHistoryCard(Presence p) {
    final date = p.formattedDate();
    final time = p.timeRangeDisplay();
    final status = p.status.label;

    // Soft color style
    final Color hadirColor = const Color(0xFF7AC27A); // soft green
    final Color izinColor = const Color(0xFFF5A25D); // soft orange

    final Color statusColor = p.status == PresenceStatus.izin
        ? izinColor
        : hadirColor;

    final IconData icon = p.status == PresenceStatus.izin
        ? Icons.note_alt
        : Icons.check_circle;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFFFF4D6), // soft lemon pastel
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================== HEADER =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TANGGAL
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.brown.shade400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ],
              ),

              // STATUS + DELETE BUTTON
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // DELETE
                  GestureDetector(
                    onTap: () => _deleteHistory(p.id),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red.shade300,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ===================== JAM =====================
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.brown.shade400),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(fontSize: 13, color: Colors.brown.shade600),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // CHECK IN
          if (p.checkInAddress != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.login, size: 16, color: hadirColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Masuk: ${p.checkInAddress}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),

          // CHECK OUT
          if (p.checkOutAddress != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.logout, size: 16, color: Colors.red.shade400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Pulang: ${p.checkOutAddress}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
