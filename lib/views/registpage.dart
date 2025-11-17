import 'package:absensi_tugas16/models/batchmodelpage.dart';
import 'package:absensi_tugas16/models/trainingmodel.dart';
import 'package:absensi_tugas16/service/api.dart';
import 'package:absensi_tugas16/views/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterSoftYellowPage extends StatefulWidget {
  const RegisterSoftYellowPage({super.key});

  @override
  State<RegisterSoftYellowPage> createState() => _RegisterSoftYellowPageState();
}

class _RegisterSoftYellowPageState extends State<RegisterSoftYellowPage>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  String? gender;
  int? batchId;
  String? batchName;
  int? trainingId;
  String? trainingName;

  bool isLoading = false;
  bool loadingBatch = true;
  bool loadingTraining = true;
  bool showPassword = false;

  List<BatchModelData> batchListApi = [];
  List<TrainingModelData> trainingListApi = [];

  late AnimationController fadeCtrl;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeAnim = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
    fadeCtrl.forward();

    loadBatch();
    loadTraining();
  }

  // ---------------- LOAD BATCH ----------------
  Future<void> loadBatch() async {
    try {
      final data = await TrainingAPI.getTrainingBatches();
      setState(() => batchListApi = data);
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal mengambil batch");
    }
    setState(() => loadingBatch = false);
  }

  // ---------------- LOAD TRAINING ----------------
  Future<void> loadTraining() async {
    try {
      final data = await TrainingAPI.getTrainings();
      setState(() => trainingListApi = data);
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal mengambil training");
    }
    setState(() => loadingTraining = false);
  }

  // ---------------- REGISTER API ----------------
  Future<void> doRegister() async {
    if (!formKey.currentState!.validate()) return;

    if (gender == null) return _show("Pilih jenis kelamin");
    if (batchId == null) return _show("Pilih batch terlebih dahulu");
    if (trainingId == null) return _show("Pilih training terlebih dahulu");

    setState(() => isLoading = true);

    try {
      final result = await AuthAPI.registerUser(
        email: emailC.text.trim(),
        name: nameC.text.trim(),
        password: passC.text.trim(),
        jenisKelamin: gender!,
        batchId: batchId!,
        trainingId: trainingId!,
      );

      _show("Registrasi berhasil! Silakan login.");

      // AUTO REDIRECT → LOGIN PAGE
      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginYellowPage()),
        );
      });
    } catch (e) {
      _show(e.toString().replaceAll("Exception:", "").trim());
    }

    setState(() => isLoading = false);
  }

  void _show(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "Create Account 🍋",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8D6E63),
                ),
              ),
              const Text(
                "Daftar sekarang dan mulai absensi 🎀",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              _cardForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _textField("Nama Lengkap", Icons.person, nameC),
            const SizedBox(height: 16),

            _emailField(),
            const SizedBox(height: 16),

            loadingBatch
                ? const CircularProgressIndicator()
                : _picker(
                    "Pilih Batch",
                    batchName,
                    batchListApi
                        .map(
                          (b) => {
                            "id": b.id.toString(),
                            "name": "Batch ${b.batchKe}",
                          },
                        )
                        .toList(),
                    (item) {
                      setState(() {
                        batchId = int.parse(item["id"]!);
                        batchName = item["name"];
                      });
                    },
                  ),

            const SizedBox(height: 16),

            _genderSelector(),
            const SizedBox(height: 16),

            loadingTraining
                ? const CircularProgressIndicator()
                : _picker(
                    "Pilih Training",
                    trainingName,
                    trainingListApi
                        .map(
                          (t) => {"id": t.id.toString(), "name": t.title ?? ""},
                        )
                        .toList(),
                    (item) {
                      setState(() {
                        trainingId = int.parse(item["id"]!);
                        trainingName = item["name"];
                      });
                    },
                  ),

            const SizedBox(height: 16),

            _passwordField(),
            const SizedBox(height: 30),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  // ================= UI FORM ELEMENTS =================

  Widget _textField(String label, IconData icon, TextEditingController c) {
    return TextFormField(
      controller: c,
      validator: (v) =>
          v == null || v.isEmpty ? "$label tidak boleh kosong" : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.yellow.shade50,
        prefixIcon: Icon(icon, color: Colors.amber.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: emailC,
      validator: (v) {
        if (v == null || v.isEmpty) return "Email tidak boleh kosong";
        if (!v.contains("@") || !v.contains("."))
          return "Format email tidak valid";
        return null;
      },
      decoration: InputDecoration(
        labelText: "Email",
        filled: true,
        fillColor: Colors.yellow.shade50,
        prefixIcon: Icon(Icons.email, color: Colors.amber.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _picker(
    String title,
    String? selected,
    List<Map<String, String>> list,
    Function(Map<String, String>) onSelect,
  ) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: list.map((item) {
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(item["name"]!),
                  onTap: () {
                    onSelect(item);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_drop_down, color: Colors.amber.shade700),
            const SizedBox(width: 10),
            Text(
              selected ?? title,
              style: TextStyle(
                color: selected == null
                    ? Colors.grey.shade600
                    : Colors.brown.shade800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _genderOption("L", "Laki-laki"),
        _genderOption("P", "Perempuan"),
      ],
    );
  }

  Widget _genderOption(String val, String title) {
    final selected = gender == val;

    return GestureDetector(
      onTap: () => setState(() => gender = val),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.amber.shade700 : Colors.grey.shade400,
                width: 2,
              ),
              color: selected ? Colors.amber.shade600 : Colors.transparent,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.amber.shade800 : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passC,
      obscureText: !showPassword,
      validator: (v) =>
          v == null || v.isEmpty ? "Password tidak boleh kosong" : null,
      decoration: InputDecoration(
        labelText: "Password",
        filled: true,
        fillColor: Colors.yellow.shade50,
        prefixIcon: Icon(Icons.lock, color: Colors.amber.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.amber.shade700,
          ),
          onPressed: () => setState(() => showPassword = !showPassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : doRegister,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Daftar Sekarang ☀️",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
