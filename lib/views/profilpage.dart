import 'package:absensi_tugas16/models/profil_model.dart';
import 'package:absensi_tugas16/preference/preference_handler.dart';
import 'package:absensi_tugas16/service/absensiapi.dart';
import 'package:absensi_tugas16/views/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileFinalPage extends StatefulWidget {
  const ProfileFinalPage({super.key});

  @override
  State<ProfileFinalPage> createState() => _ProfileFinalPageState();
}

class _ProfileFinalPageState extends State<ProfileFinalPage> {
  bool loading = true;

  ProfileModel? profile;
  Data? user;

  final nameC = TextEditingController();
  final emailC = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ============================================
  // LOAD PROFILE
  // ============================================
  Future<void> loadProfile() async {
    try {
      final res = await AbsensiAPI.getProfile();
      profile = ProfileModel.fromJson(res);
      user = profile?.data;

      nameC.text = user?.name ?? "";
      emailC.text = user?.email ?? "";
    } catch (e) {
      debugPrint("Error load profile: $e");
    }

    setState(() => loading = false);
  }

  // ============================================
  // LOGOUT
  // ============================================
  Future<void> doLogout() async {
    await PreferenceHandler.removeToken();
    await PreferenceHandler.removeLogin();
    await PreferenceHandler.removeName();

    if (!mounted) return;

    Fluttertoast.showToast(msg: "Logout berhasil");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginCustGlow()),
      (route) => false,
    );
  }

  // ============================================
  // DELETE ABSEN
  // ============================================
  // Future<void> deleteAllAbsen() async {
  //   if (user?.id == null) return;
  //   try {
  //     await AbsensiAPI.deleteAbsen(user!.id!);
  //     Fluttertoast.showToast(msg: "Semua absen berhasil dihapus");
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Gagal menghapus absen");
  //   }
  // }

  // void confirmDeleteAbsen() {
  //   showDialog(
  //     context: context,
  //     builder: (c) {
  //       return AlertDialog(
  //         title: const Text("Hapus Semua Absen?"),
  //         content: const Text(
  //           "Data absensi akan hilang permanen dan tidak bisa dikembalikan.",
  //         ),
  //         actions: [
  //           TextButton(
  //             child: const Text("Batal"),
  //             onPressed: () => Navigator.pop(c),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //             child: const Text("Hapus"),
  //             onPressed: () async {
  //               Navigator.pop(c);
  //               await deleteAllAbsen();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // ============================================
  // EDIT PROFILE (NAMA SAJA)
  // ============================================
  void showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
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
                  width: 45,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Edit Profil",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _label("Nama Lengkap"),
              _input(nameC, enabled: true),
              const SizedBox(height: 16),

              _label("Email"),
              _input(emailC, enabled: false), // EMAIL TERKUNCI

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    try {
                      await AbsensiAPI.editProfile(name: nameC.text.trim());

                      Fluttertoast.showToast(msg: "Profil berhasil diperbarui");
                      loadProfile();
                    } catch (e) {
                      Fluttertoast.showToast(msg: "Gagal update profil");
                    }
                  },
                  child: const Text("Simpan Perubahan"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.brown.shade700,
      ),
    );
  }

  Widget _input(TextEditingController c, {required bool enabled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: enabled ? Colors.grey.shade100 : Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: c,
        enabled: enabled,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey.shade600),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  // ============================================
  // UI MAIN
  // ============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E5),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Profil Saya 🍋",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),

          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orange.shade300,
            backgroundImage: (user?.profilePhoto != null)
                ? NetworkImage(user!.profilePhoto!)
                : null,
            child: (user?.profilePhoto == null)
                ? Text(
                    (user?.name?[0] ?? "?").toUpperCase(),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 14),

          Text(
            user?.name ?? "-",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            user?.email ?? "-",
            style: TextStyle(fontSize: 15, color: Colors.brown.shade600),
          ),

          const SizedBox(height: 20),

          _infoCard(),

          const SizedBox(height: 24),

          _mainButton("Edit Profil", Colors.orange.shade500, showEditSheet),
          const SizedBox(height: 10),

          // _mainButton(
          //   "Hapus Semua Absen",
          //   Colors.red.shade300,
          //   confirmDeleteAbsen,
          // ),
          const SizedBox(height: 10),

          _mainButton("Keluar Akun", Colors.red.shade500, doLogout),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _mainButton(String title, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow("Nama", user?.name),
          _infoRow("Email", user?.email),
          _infoRow("Training", user?.training?.title),
          _infoRow("Batch", user?.batch?.batchKe),
          _infoRow("Jenis Kelamin", user?.jenisKelamin),
        ],
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade800,
            ),
          ),
          Text(
            value?.toString() ?? "-",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
