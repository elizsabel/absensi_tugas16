import 'package:absensi_tugas16/preference/shared_preferences';
import 'package:absensi_tugas16/service/api.dart';
import 'package:flutter/material.dart';

class LoginYellowPage extends StatefulWidget {
  const LoginYellowPage({super.key});

  @override
  State<LoginYellowPage> createState() => _LoginYellowPageState();
}

class _LoginYellowPageState extends State<LoginYellowPage>
    with TickerProviderStateMixin {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool showPass = false;
  bool isLoading = false;

  late AnimationController fadeCtrl;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnim = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
    fadeCtrl.forward();
  }

  Future<void> doLogin() async {
    if (emailC.text.isEmpty) return _show("Email belum diisi");
    if (passC.text.isEmpty) return _show("Password belum diisi");

    setState(() => isLoading = true);

    try {
      final result = await AuthAPI.loginUser(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      // save token
      if (result.data?.token != null) {
        await PreferenceHandler.saveToken(result.data!.token!);
      }

      setState(() => isLoading = false);

      _show("Login berhasil 🎉");

      // TODO: arahkan ke dashboard
      // Navigator.pushReplacement(...)
    } catch (e) {
      setState(() => isLoading = false);
      _show("Login gagal: $e");
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
              const SizedBox(height: 80),
              const Text(
                "Welcome Back ☀️",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Masuk ke akun kamu untuk melanjutkan",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 40),
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
      child: Column(
        children: [
          _inputField("Email", Icons.email, emailC),
          const SizedBox(height: 16),
          _passwordField(),
          const SizedBox(height: 30),
          _loginButton(),
        ],
      ),
    );
  }

  Widget _inputField(String label, IconData icon, TextEditingController c) {
    return TextField(
      controller: c,
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

  Widget _passwordField() {
    return TextField(
      controller: passC,
      obscureText: !showPass,
      decoration: InputDecoration(
        labelText: "Password",
        filled: true,
        fillColor: Colors.yellow.shade50,
        prefixIcon: Icon(Icons.lock, color: Colors.amber.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            showPass ? Icons.visibility : Icons.visibility_off,
            color: Colors.amber.shade700,
          ),
          onPressed: () => setState(() => showPass = !showPass),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _loginButton() {
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
        onPressed: isLoading ? null : doLogin,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Masuk Sekarang 🍋",
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
