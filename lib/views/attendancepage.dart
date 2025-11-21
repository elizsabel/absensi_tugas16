import 'dart:io';

import 'package:absensi_tugas16/models/attendance2.dart';
import 'package:absensi_tugas16/service/absensiapi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String address = "Mengambil lokasi…";
  Position? position;

  // izin
  String izinSelected = "Sakit";
  final alasanC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      LocationPermission perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemark = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      final p = placemark.first;

      setState(() {
        address =
            "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9D9), // tema kuning lemon
      appBar: AppBar(
        title: const Text(
          "Absensi",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.brown),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.brown.shade700,
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Silakan pilih jenis absensi:",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 22),

            // ================= CHECK IN =================
            _menuButton(
              label: "Masuk",
              subtitle: "Absen saat mulai bekerja",
              icon: Icons.login_rounded,
              colors: const [Color(0xFFFFD88A), Color(0xFFFFE9B6)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceDetailPage(isCheckIn: true),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ================= CHECK OUT =================
            _menuButton(
              label: "Pulang",
              subtitle: "Absen saat selesai bekerja",
              icon: Icons.logout_rounded,
              colors: const [Color(0xFFFFB9A8), Color(0xFFFFD2C8)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AttendanceDetailPage(isCheckIn: false),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ================= AJUKAN IZIN =================
            _menuButton(
              label: "Ajukan Izin",
              subtitle: "Sakit • Izin • Dinas",
              icon: Icons.note_alt_rounded,
              colors: const [Color(0xFFB8CCFF), Color(0xFFDCE7FF)],
              onTap: _openIzinSheet,
              big: true,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= BUTTON =================
  Widget _menuButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    bool big = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: big ? 20 : 16, horizontal: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(icon, color: colors.first, size: 22),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= IZIN SHEET =================
  void _openIzinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Ajukan Izin 🍋",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Pilih jenis izin & isi keterangan singkat ya",
                style: TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _izinOption("Sakit", Colors.blue),
                  const SizedBox(width: 10),
                  _izinOption("Izin", Colors.orange),
                  const SizedBox(width: 10),
                  _izinOption("Dinas", Colors.green),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Keterangan:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: alasanC,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitIzin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Kirim Izin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _izinOption(String title, Color color) {
    final active = izinSelected == title;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => izinSelected = title),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.2) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: active ? color : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(Icons.note_alt_rounded, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitIzin() async {
    Navigator.pop(context);

    await AbsensiAPI.izin(
      date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
      alasan: "$izinSelected - ${alasanC.text}",
    );

    Fluttertoast.showToast(msg: "Izin berhasil diajukan 🍋");

    alasanC.clear();
  }
}

class AttendanceDetailPage extends StatefulWidget {
  final bool isCheckIn;

  const AttendanceDetailPage({super.key, required this.isCheckIn});

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage>
    with SingleTickerProviderStateMixin {
  Position? position;
  String address = "Mengambil lokasi…";
  File? imageFile;
  bool loading = false;

  DataAttend? todayData;

  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

    await Future.wait([_getLocation(), _loadTodayAttendance()]);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ==================== GET LOCATION ====================
  Future<void> _getLocation() async {
    try {
      LocationPermission perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemark = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      final p = placemark.first;

      setState(() {
        address =
            "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
      });
    } catch (_) {}
  }

  // ==================== TODAY DATA ====================
  Future<void> _loadTodayAttendance() async {
    try {
      final res = await AbsensiAPI.getHistory();
      final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());

      final match = res.where((e) => e.attendanceDate == todayStr);
      if (match.isNotEmpty) todayData = match.first;
    } catch (_) {}

    setState(() {});
  }

  // ==================== PICK IMAGE ====================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);

    if (img != null) {
      setState(() => imageFile = File(img.path));
    }
  }

  // ==================== SUBMIT ====================
  Future<void> _submitAttendance() async {
    if (position == null) {
      Fluttertoast.showToast(msg: "Lokasi belum ditemukan");
      return;
    }

    if (imageFile == null) {
      Fluttertoast.showToast(msg: "Ambil foto terlebih dahulu");
      return;
    }

    setState(() => loading = true);

    final now = DateTime.now();

    try {
      if (widget.isCheckIn) {
        await AbsensiAPI.checkIn(
          attendanceDate: DateFormat("yyyy-MM-dd").format(now),
          time: DateFormat("HH:mm").format(now),
          lat: position!.latitude,
          lng: position!.longitude,
          address: address,
        );
      } else {
        await AbsensiAPI.checkOut(
          attendanceDate: DateFormat("yyyy-MM-dd").format(now),
          time: DateFormat("HH:mm").format(now),
          lat: position!.latitude,
          lng: position!.longitude,
          address: address,
        );
      }

      Fluttertoast.showToast(
        msg: widget.isCheckIn
            ? "Check-In berhasil! 🍋"
            : "Check-Out berhasil! 🍋",
      );

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal: $e");
    }

    setState(() => loading = false);
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    final title = widget.isCheckIn ? "Absen Masuk" : "Absen Pulang";

    final lemonColor = widget.isCheckIn
        ? const Color(0xFFFFD88A) // kuning pastel check-in
        : const Color(0xFFFFB9A8); // peach pastel check-out

    final submitColor = widget.isCheckIn
        ? const Color(0xFFFFC950)
        : const Color(0xFFFF9E8F);

    final hasCheckIn = (todayData?.checkInTime ?? "").isNotEmpty;
    final hasCheckOut = (todayData?.checkOutTime ?? "").isNotEmpty;

    final statusText = widget.isCheckIn
        ? (hasCheckIn ? "Sudah Check In" : "Belum Check In")
        : (hasCheckOut ? "Sudah Check Out" : "Belum Check Out");

    final now = DateTime.now();
    final dayName = DateFormat("EEEE", "id_ID").format(now);
    final dateShort = DateFormat("dd MMMM yyyy", "id_ID").format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9D9),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.brown,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.brown,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ================= MAP =================
                    SizedBox(
                      height: 270,
                      child: position == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  position!.latitude,
                                  position!.longitude,
                                ),
                                zoom: 16,
                              ),
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                            ),
                    ),

                    // ================= WHITE SHEET =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // STATUS
                          Row(
                            children: [
                              const Text(
                                "Status: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: lemonColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Alamat:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address,
                            style: const TextStyle(height: 1.4, fontSize: 13),
                          ),

                          const SizedBox(height: 18),

                          // ============== CARD WAKTU ==============
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF7),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade200),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Hari & tanggal
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dayName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.brown.shade600,
                                      ),
                                    ),
                                    Text(
                                      dateShort,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),

                                // Check In & Check Out
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Check In",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          todayData?.checkInTime ?? "-- : --",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(width: 20),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Check Out",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          todayData?.checkOutTime ?? "-- : --",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ============ TAKE PHOTO BUTTON ============
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFE6A6),
                                    Color(0xFFFFF2CE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      imageFile == null
                                          ? "Ambil Foto"
                                          : "Ulangi Foto",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if (imageFile != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              "Foto sudah diambil ✔",
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                          ],

                          const SizedBox(height: 30),

                          // SUBMIT BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _submitAttendance,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: submitColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                widget.isCheckIn
                                    ? "Check In Sekarang"
                                    : "Check Out Sekarang",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
