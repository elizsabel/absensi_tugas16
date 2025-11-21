import 'dart:convert';
import 'dart:io';
import 'package:absensi_tugas16/models/batchmodelpage.dart';
import 'package:absensi_tugas16/models/trainingmodel.dart';
import 'package:absensi_tugas16/preference/preference_handler.dart';
import 'package:absensi_tugas16/service/api.dart';
import 'package:absensi_tugas16/views/loginpage.dart';
import 'package:absensi_tugas16/widgets/login_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class RegisterCuteYellow extends StatefulWidget {
  const RegisterCuteYellow({super.key});

  @override
  State<RegisterCuteYellow> createState() => _RegisterCuteYellowState();
}

class _RegisterCuteYellowState extends State<RegisterCuteYellow> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final nameC = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isPassVisible = false;

  List<TrainingModelData> trainings = [];
  List<BatchModelData> batches = [];

  int? selectedBatchId;
  int? selectedTrainingId;
  String? selectedGender;

  File? pickedImage;
  String? profileBase64;

  @override
  void initState() {
    super.initState();
    loadDropdown();
  }

  Future<void> loadDropdown() async {
    try {
      final t = await TrainingAPI.getTrainings();
      final b = await TrainingAPI.getTrainingBatches();
      setState(() {
        trainings = t;
        batches = b;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat data dropdown");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        pickedImage = File(file.path);
        profileBase64 = "data:image/jpeg;base64,${base64Encode(bytes)}";
      });
    }
  }

  Future<void> doRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null ||
        selectedBatchId == null ||
        selectedTrainingId == null) {
      Fluttertoast.showToast(msg: "Semua field wajib diisi!");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthAPI.registerUser(
        email: emailC.text.trim(),
        name: nameC.text.trim(),
        password: passC.text.trim(),
        jenisKelamin: selectedGender!,
        batchId: selectedBatchId!,
        trainingId: selectedTrainingId!,
        profilePhoto: profileBase64 ?? "",
      );

      if (result.data?.token != null) {
        await PreferenceHandler.saveToken(result.data!.token!);
      }

      Fluttertoast.showToast(msg: "Registrasi Berhasil 🍋✨");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginCustGlow()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => isLoading = false);
  }

  // =========================================================
  // UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              Text(
                "Create Account 🍋",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.brown.shade700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Daftar sekarang dan mulai absensi ☀️",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // FOTO PROFIL
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade300,
                                Colors.yellow.shade200,
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            backgroundImage: pickedImage != null
                                ? FileImage(pickedImage!)
                                : null,
                            child: pickedImage == null
                                ? Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color: Colors.amber.shade700,
                                  )
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Email
                      textField(
                        label: "Email",
                        controller: emailC,
                        icon: Icons.email_outlined,
                        validator: (v) => v!.isEmpty ? "Isi email" : null,
                      ),

                      const SizedBox(height: 14),

                      // Password
                      passwordField(),

                      const SizedBox(height: 14),

                      // Nama
                      textField(
                        label: "Nama Lengkap",
                        controller: nameC,
                        icon: Icons.person,
                        validator: (v) =>
                            v!.isEmpty ? "Isi nama lengkap" : null,
                      ),

                      const SizedBox(height: 20),

                      // Gender Button
                      buildGenderSelector(),

                      const SizedBox(height: 20),

                      // Dropdown Training
                      buildDropdownTraining(),

                      const SizedBox(height: 20),

                      // Dropdown Batch
                      buildDropdownBatch(),

                      const SizedBox(height: 30),

                      LoginButton(
                        text: "Daftar Sekarang ☀️",
                        isLoading: isLoading,
                        onPressed: doRegister,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginCustGlow()),
                    ),
                    child: Text(
                      "Masuk",
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // FIELD REUSABLE
  // =========================================================
  Widget textField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPass = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      validator: validator,
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

  // =========================================================
  // GENDER BUTTON
  // =========================================================
  Widget buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jenis Kelamin",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: genderButton(
                label: "Laki-laki",
                icon: Icons.male,
                active: selectedGender == "L",
                onTap: () => setState(() => selectedGender = "L"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: genderButton(
                label: "Perempuan",
                icon: Icons.female,
                active: selectedGender == "P",
                onTap: () => setState(() => selectedGender = "P"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget genderButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? Colors.amber.shade300 : Colors.yellow.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? Colors.amber : Colors.grey.shade300,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.brown, size: 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DROPDOWN TRAINING
  // =========================================================
  Widget buildDropdownTraining() {
    return DropdownButtonFormField<int>(
      decoration: cuteDropdownDecoration().copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      value: selectedTrainingId,
      items: trainings.map((e) {
        return DropdownMenuItem(
          value: e.id,
          child: Row(
            children: [
              Icon(Icons.school, size: 18, color: Colors.amber.shade600),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  e.title ?? "",
                  overflow: TextOverflow.ellipsis, // ⬅ cegah text panjang
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => selectedTrainingId = v),
      validator: (v) => v == null ? "Pilih training" : null,
    );
  }

  // =========================================================
  // DROPDOWN BATCH
  // =========================================================
  Widget buildDropdownBatch() {
    return DropdownButtonFormField<int>(
      decoration: cuteDropdownDecoration(),
      value: selectedBatchId,
      items: batches
          .map(
            (b) => DropdownMenuItem(
              value: b.id,
              child: Row(
                children: [
                  Icon(Icons.date_range, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text("Batch ${b.batchKe}"),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => selectedBatchId = v),
      validator: (v) => v == null ? "Pilih batch" : null,
    );
  }

  Widget passwordField() {
    return TextFormField(
      controller: passC,
      obscureText: !isPassVisible,
      validator: (v) => v!.isEmpty ? "Isi password" : null,
      decoration: InputDecoration(
        labelText: "Password",
        filled: true,
        fillColor: Colors.yellow.shade50,
        prefixIcon: Icon(Icons.lock, color: Colors.amber.shade700),

        //  ICON SHOW/HIDE PASSWORD
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isPassVisible = !isPassVisible;
            });
          },
          icon: Icon(
            isPassVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.amber.shade700,
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // CUTE DROPDOWN DECORATION

  InputDecoration cuteDropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.yellow.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.amber.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.amber.shade700, width: 2),
      ),
    );
  }
}
