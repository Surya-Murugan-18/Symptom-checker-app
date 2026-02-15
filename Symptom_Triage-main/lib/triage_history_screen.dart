import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class TriageHistoryItem {
  final String date;
  final String urgency;
  final String symptom;
  final String reasoning;
  final List<String> recommendations;

  TriageHistoryItem({
    required this.date,
    required this.urgency,
    required this.symptom,
    required this.reasoning,
    required this.recommendations,
  });
}

class TriageHistoryManager {
  static final List<TriageHistoryItem> history = [
    // Mock data for demo
    TriageHistoryItem(
      date: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now().subtract(const Duration(days: 2))),
      urgency: 'high',
      symptom: 'Severe Chest Pain',
      reasoning: 'Red flag red-zone symptom detected matching cardiovascular emergency protocols.',
      recommendations: ['Contacted emergency services', 'Aspirin administered', 'Ambulance dispatched'],
    ),
    TriageHistoryItem(
      date: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now().subtract(const Duration(days: 5))),
      urgency: 'low',
      symptom: 'Mild Skin Rash',
      reasoning: 'Stable allergic reaction localized to upper arm. No respiratory distress.',
      recommendations: ['Antihistamine cream', 'Cool compress', 'Avoid scratch'],
    ),
  ];

  static void add(TriageHistoryItem item) {
    history.insert(0, item);
  }
}

class TriageHistoryScreen extends StatelessWidget {
  const TriageHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Medical Triage History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
      ),
      body: TriageHistoryManager.history.isEmpty 
        ? const Center(child: Text("No triage reports found."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: TriageHistoryManager.history.length,
            itemBuilder: (context, index) {
              final item = TriageHistoryManager.history[index];
              final isHigh = item.urgency == 'high';
              final color = isHigh ? Colors.red : (item.urgency == 'mid' ? Colors.orange : Colors.green);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.activity, color: color, size: 18),
                          const SizedBox(width: 8),
                          Text(item.urgency.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(item.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Symptom: ${item.symptom}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(item.reasoning, style: const TextStyle(color: Color(0xFF718086), fontSize: 13)),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${item.recommendations.length} Recommendations", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF Downloading...")));
                                },
                                icon: Icon(LucideIcons.download, size: 14),
                                label: const Text("Download PDF"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2BA395),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
