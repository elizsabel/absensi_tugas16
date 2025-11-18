// lib/features/presence/pages/riwayat_page.dart

import 'package:absensi_tugas16/models/presence_history_model.dart';
import 'package:flutter/material.dart';
import 'package:absensi_tugas16/service/absensiapi.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool loading = true;
  List<Presence> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => loading = true);

    try {
      final res = await AbsensiAPI.getHistory();

      // PARSE KE MODEL KAKAK
      final model = PresenceHistoryModel.fromJson(res);

      setState(() {
        history = model.data;
      });
    } catch (e) {
      print("Error load history: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8E7),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade300,
        title: const Text("Riwayat Absensi"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text("Belum ada riwayat absen"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (ctx, i) {
                final p = history[i];

                return _buildHistoryCard(p);
              },
            ),
    );
  }

  // =============================
  // CARD UI
  // =============================
  Widget _buildHistoryCard(Presence p) {
    final date = p.formattedDate();
    final time = p.timeRangeDisplay();
    final status = p.status.label;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TANGGAL
          Text(
            "📆 $date",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // JAM
          Text(
            "⏰ $time",
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),

          const SizedBox(height: 6),

          // STATUS
          Row(
            children: [
              Icon(
                p.status == PresenceStatus.izin
                    ? Icons.note_alt
                    : Icons.check_circle,
                color: p.status == PresenceStatus.izin
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: p.status == PresenceStatus.izin
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ],
          ),

          if (p.alasanIzin != null && p.alasanIzin!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "📝 Alasan: ${p.alasanIzin}",
              style: const TextStyle(color: Colors.black87),
            ),
          ],

          const SizedBox(height: 10),

          // CHECK IN ADDRESS
          if (p.checkInAddress != null) ...[
            Text(
              "📍 Masuk: ${p.checkInAddress}",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],

          // CHECK OUT ADDRESS
          if (p.checkOutAddress != null) ...[
            Text(
              "📍 Pulang: ${p.checkOutAddress}",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}
