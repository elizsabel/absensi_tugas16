import 'package:absensi_tugas16/preference/preference_handler.dart';
import 'package:absensi_tugas16/service/api.dart';
import 'package:absensi_tugas16/views/dashboard.dart';
import 'package:absensi_tugas16/views/registpage.dart';
import 'package:absensi_tugas16/widgets/main_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginCustGlow extends StatefulWidget {
  const LoginCustGlow({super.key});
  static const id = "/logincust";

  @override
  State<LoginCustGlow> createState() => _LoginCustGlowState();
}

class _LoginCustGlowState extends State<LoginCustGlow> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  bool isPassVisible = false;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [buildBackground(), buildLoginForm()]),
    );
  }

  /// ===================== UI =====================
  SafeArea buildLoginForm() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 120, 22, 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Welcome Back 🍋",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.brown.shade700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Masuk untuk melanjutkan absensi",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 35),

              /// ===================== CARD =====================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// EMAIL
                    buildTitle("Email"),
                    buildInput(
                      controller: emailC,
                      hint: "Masukkan email",
                      icon: Icons.email_outlined,
                      validator: (v) {
                        if (v!.isEmpty) return "Email tidak boleh kosong";
                        if (!v.contains("@")) return "Email tidak valid";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// PASSWORD
                    buildTitle("Password"),
                    buildInput(
                      controller: passC,
                      hint: "Masukkan password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) =>
                          v!.isEmpty ? "Password tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 28),

                    /// LOGIN BUTTON
                    LoginYellowButton(
                      text: "Masuk Sekarang ☀️",
                      isLoading: isLoading,
                      onPressed: loginUser,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterCuteYellow(),
                        ),
                      );
                    },
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
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

  /// ===================== LOGIN API =====================
  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final result = await AuthAPI.loginUser(
          email: emailC.text.trim(),
          password: passC.text.trim(),
        );

        setState(() => isLoading = false);

        if (result.data?.token != null) {
          await PreferenceHandler.saveToken(result.data!.token!);
          await PreferenceHandler.saveName(result.data!.user!.name!);
        }

        Fluttertoast.showToast(msg: "Login berhasil! 🎉");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainBottomNav()),
        );
      } catch (e) {
        setState(() => isLoading = false);
        Fluttertoast.showToast(msg: "Login gagal: ${e.toString()}");
      }
    }
  }

  /// ===================== INPUT FIELD =====================
  Widget buildTitle(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.brown,
        fontSize: 14,
      ),
    ),
  );

  Widget buildInput({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: isPassword ? !isPassVisible : false,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.yellow.shade50,
        prefixIcon: Icon(icon, color: Colors.amber.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () => setState(() => isPassVisible = !isPassVisible),
                icon: Icon(
                  isPassVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.amber.shade700,
                ),
              )
            : null,
      ),
    );
  }

  /// ===================== BACKGROUND =====================
  Widget buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF7D1), Color(0xFFFFF3C4), Color(0xFFFFFAF0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

/// ===================== YELLOW BUTTON =====================
class LoginYellowButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final bool isLoading;

  const LoginYellowButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
