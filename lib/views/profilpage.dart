// ======================================================
// PROFILE PAGE – SOFT PASTEL LEMON 🍋✨
// ======================================================

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

  // LOAD PROFILE
  Future<void> loadProfile() async {
    try {
      final res = await AbsensiAPI.getProfile();
      profile = ProfileModel.fromJson(res);
      user = profile?.data;

      nameC.text = user?.name ?? "";
      emailC.text = user?.email ?? "";
    } catch (e) {}

    setState(() => loading = false);
  }

  // LOGOUT
  Future<void> doLogout() async {
    await PreferenceHandler.removeToken();
    await PreferenceHandler.removeLogin();
    await PreferenceHandler.removeName();

    Fluttertoast.showToast(msg: "Logout berhasil");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginCustGlow()),
      (route) => false,
    );
  }

  // ================= EDIT PROFILE SHEET =================
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
              _input(emailC, enabled: false),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB84C),
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
        color: Colors.brown.shade600,
      ),
    );
  }

  Widget _input(TextEditingController c, {required bool enabled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: enabled ? Colors.white : Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: c,
        enabled: enabled,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey.shade600),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD88A), // LEMON SOFT
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profil Saya 🍋",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ================= AVATAR =================
          CircleAvatar(
            radius: 52,
            backgroundColor: const Color(0xFFFFDFAE), // LEMON PASTEL
            backgroundImage: (user?.profilePhoto != null)
                ? NetworkImage(user!.profilePhoto!)
                : null,
            child: user?.profilePhoto == null
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

          Text(
            user?.email ?? "-",
            style: TextStyle(fontSize: 15, color: Colors.brown.shade600),
          ),

          const SizedBox(height: 22),

          _infoCard(),

          const SizedBox(height: 26),

          _mainButton("Edit Profil", const Color(0xFFFFB84C), showEditSheet),
          const SizedBox(height: 12),

          _mainButton("Keluar Akun", Colors.red.shade400, doLogout),

          const SizedBox(height: 90),
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
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFFFF4D6), // soft lemon
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              color: Colors.brown.shade700,
            ),
          ),
          Text(
            value?.toString() ?? "-",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
