import 'package:flutter/material.dart';
import 'package:absensi_tugas16/service/absensiapi.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final res = await AbsensiAPI.getProfile();
      setState(() {
        profile = res["data"];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade50,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade50,
        elevation: 0,
        title: const Text("Profil Pengguna"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text("Gagal memuat profil"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person, size: 80),
                      const SizedBox(height: 20),
                      Text("Nama: ${profile!["name"]}"),
                      Text("Email: ${profile!["email"]}"),
                      Text("Batch: ${profile!["batch_id"] ?? '-'}"),
                      Text("Training: ${profile!["training_id"] ?? '-'}"),
                    ],
                  ),
                ),
    );
  }
}
