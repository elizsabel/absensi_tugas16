import 'package:flutter/material.dart';
import 'package:absensi_tugas16/models/presence_history_model.dart';
import 'package:absensi_tugas16/service/absensiapi.dart';
import 'package:intl/intl.dart';

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
      final model = PresenceHistoryModel.fromJson(res);

      setState(() => history = model.data);
    } catch (e) {
      debugPrint("Error load history: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E5),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Riwayat Absensi 🍋",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: Colors.orange,
              onRefresh: loadHistory,
              child: history.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: history.length,
                      itemBuilder: (_, i) => _buildHistoryCard(history[i]),
                    ),
            ),
    );
  }

  // ============================= EMPTY VIEW =============================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.orange.shade300),
          const SizedBox(height: 10),
          Text(
            "Belum ada riwayat absensi",
            style: TextStyle(fontSize: 16, color: Colors.brown.shade600),
          ),
        ],
      ),
    );
  }

  // ============================= CARD UI =============================
  Widget _buildHistoryCard(Presence p) {
    final date = p.formattedDate();
    final time = p.timeRangeDisplay();
    final status = p.status.label;

    // Warna status
    Color statusColor;
    IconData icon;

    switch (p.status) {
      case PresenceStatus.izin:
        statusColor = Colors.orange;
        icon = Icons.note_alt;
        break;
      default:
        statusColor = Colors.green;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER (tanggal + status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT: Tanggal
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.brown,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              // RIGHT: Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: statusColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // JAM
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: Colors.brown),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),

          if (p.alasanIzin != null && p.alasanIzin!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.note, size: 18, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Alasan: ${p.alasanIzin}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // LOKASI MASUK
          if (p.checkInAddress != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Masuk: ${p.checkInAddress}",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // LOKASI PULANG
          if (p.checkOutAddress != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.logout, size: 18, color: Colors.red.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Pulang: ${p.checkOutAddress}",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
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
