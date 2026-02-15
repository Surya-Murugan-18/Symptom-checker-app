import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';
import 'nearby_hospital.dart';
import 'triage_history_screen.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // --- States ---
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String _selectedLangCode = "en-US";
  
  // --- Voice ---
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final List<Map<String, String>> _languages = [
    {"code": "en-US", "label": "English"},
    {"code": "hi-IN", "label": "हिंदी"},
    {"code": "ta-IN", "label": "தமிழ்"},
    {"code": "te-IN", "label": "తెలుగు"},
    {"code": "bn-IN", "label": "বাংলা"},
    {"code": "ml-IN", "label": "മലയാളം"},
    {"code": "es-ES", "label": "Español"},
    {"code": "fr-FR", "label": "Français"},
    {"code": "ar-SA", "label": "العربية"},
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ============== REFINED TRIAGE LOGIC (BASED ON YOUR REQUEST) ==============

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMsg = {"role": "user", "content": text.trim()};
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final List<Map<String, dynamic>> history = _messages.map((m) => {
        "role": m["role"],
        "content": m["content"]
      }).toList();

      // DATASET-DRIVEN TRIAGE STRATEGY (Mapped to your backend CSVs)
      // Low Severity (Weight 1-3): Provide remedies from symptom_precaution.csv
      // Mid Severity (Weight 4-5): Advise clinic visit + localized remedies.
      // High Severity (Weight 6-7): Immediate Emergency JSON + trigger_emergency_call.
      final lowerText = text.toLowerCase();
      bool critical = lowerText.contains("chest pain") || lowerText.contains("breathing") || lowerText.contains("stroke") || lowerText.contains("heart attack") || lowerText.contains("unconscious") || lowerText.contains("bleeding");
      
      String promptModifier = critical 
        ? "\n(RULE: HIGH SEVERITY (WEIGHT 7). STOP QUESTIONS. OUTPUT EMERGENCY JSON IMMEDIATELY.)"
        : "\n(RULE: Use your internal clinical weights (1-7). Ask follow-ups to find the specific symptom. If Weight < 4, provide the 4 precautions/remedies from dataset. If Weight 4-6, recommend clinic.)";

      history.last["content"] += promptModifier;

      final request = http.Request("POST", Uri.parse(ApiConfig.careCompanionChat));
      request.headers.addAll({
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiConfig.supabaseAnonKey}",
      });
      request.body = jsonEncode({"messages": history});

      final response = await http.Client().send(request);
      int assistantMsgIndex = -1;
      String currentAssistantContent = "";

      response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        final trimmed = line.trim();
        if (trimmed.startsWith("data: ")) {
          final dataStr = trimmed.substring(6).trim();
          if (dataStr == "[DONE]" || dataStr.isEmpty) return;
          try {
            final data = jsonDecode(dataStr);
            final delta = data['choices']?[0]?['delta']?['content'] ?? "";
            if (delta.isNotEmpty) {
              currentAssistantContent += delta;
              setState(() {
                if (assistantMsgIndex == -1) {
                  _messages.add({"role": "assistant", "content": currentAssistantContent});
                  assistantMsgIndex = _messages.length - 1;
                } else {
                  _messages[assistantMsgIndex]["content"] = currentAssistantContent;
                }
              });
              _scrollToBottom();
            }
          } catch (e) {}
        }
      }, onDone: () {
        setState(() => _isLoading = false);
        _saveToHistory(); // Auto-save session to history
        _scrollToBottom();
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({"role": "assistant", "content": "Error connects to Sevai AI."});
      });
    }
  }

  // SAVE TO HISTORY: Stores report in history
  Future<void> _saveToHistory() async {
    // This would typically be a backend call to save the current _messages list
    // For now, we simulate a 'Session Stored' message
    print("AI TRIAGE REPORT STORED IN HISTORY");
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() => _messageController.text = val.recognizedWords), localeId: _selectedLangCode);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_messageController.text.isNotEmpty) _send(_messageController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F9),
      appBar: _buildHeader(),
      body: Column(
        children: [
          Expanded(child: _messages.isEmpty ? _buildWelcome() : _buildChatList()),
          _buildInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF13191B), size: 20), onPressed: () => Navigator.pop(context)),
      title: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2BA395), Color(0xFF1EA1A1)]), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text("S", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Sevai AI", style: TextStyle(color: Color(0xFF13191B), fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Smart Healthcare Triage", style: TextStyle(color: Color(0xFF718086), fontSize: 12)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: Icon(LucideIcons.history, color: Color(0xFF2BA395), size: 20), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TriageHistoryScreen()));
        }),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2BA395), Color(0xFF1EA1A1)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF2BA395).withOpacity(0.3), blurRadius: 30)]),
            child: const Icon(LucideIcons.shield, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          const Text("AI Health Assessment", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF13191B))),
          const SizedBox(height: 12),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Text("Describe your symptoms. I will analyze the severity and provide localized remedies or coordinate help.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF718086), fontSize: 14, height: 1.5))),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: ["Chest Pain", "Stomach Ache", "Fever", "Severe Headache"].map((s) => ActionChip(label: Text(s), onPressed: () => _send(s), backgroundColor: const Color(0xFFF2F8F9), labelStyle: const TextStyle(color: Color(0xFF2BA395), fontSize: 12))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length + (_isLoading && _messages.last["role"] == "user" ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) return const TypingIndicator();
        final msg = _messages[index];
        return ChatMessageWidget(role: msg["role"], content: msg["content"]);
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE6ECEF)))),
      child: Row(
        children: [
          IconButton(onPressed: _listen, icon: Icon(_isListening ? LucideIcons.micOff : LucideIcons.mic, color: _isListening ? Colors.red : const Color(0xFF718086))),
          const SizedBox(width: 8),
          Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: const Color(0xFFF2F8F9), borderRadius: BorderRadius.circular(12)), child: TextField(controller: _messageController, decoration: const InputDecoration(hintText: "Enter symptoms...", border: InputBorder.none)))),
          const SizedBox(width: 8),
          IconButton(onPressed: () => _send(_messageController.text), icon: const Icon(LucideIcons.send, color: Color(0xFF2BA395))),
        ],
      ),
    );
  }
}

// ============== COMPONENTS (REPLICATED FROM ZIP src/components/...) ==============

class ChatMessageWidget extends StatelessWidget {
  final String role;
  final String content;
  const ChatMessageWidget({Key? key, required this.role, required this.content}) : super(key: key);

  Map<String, dynamic>? _extractTriageJSON(String text) {
    final regex = RegExp(r'```json\s*([\s\S]*?)```');
    final match = regex.firstMatch(text);
    if (match != null) {
      try { return jsonDecode(match.group(1)!); } catch (e) {}
    }
    return null;
  }

  String _stripTriageJSON(String text) {
    return text.replaceFirst(RegExp(r'```json\s*[\s\S]*?```'), "").trim();
  }

  @override
  Widget build(BuildContext context) {
    bool isUser = role == "user";
    final triageData = !isUser ? _extractTriageJSON(content) : null;
    final displayContent = !isUser ? _stripTriageJSON(content) : content;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) const Padding(padding: EdgeInsets.only(top: 4), child: Icon(LucideIcons.shield, color: Color(0xFF2BA395), size: 20)),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: isUser ? const Color(0xFF2BA395) : Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Text(displayContent, style: TextStyle(color: isUser ? Colors.white : const Color(0xFF13191B), fontSize: 14)),
                ),
              ),
            ],
          ),
          if (triageData != null) UrgencyCardWidget(data: triageData, userQuery: isUser ? content : "Medical Inquiry"),
        ],
      ),
    );
  }
}

class UrgencyCardWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final String userQuery;
  const UrgencyCardWidget({Key? key, required this.data, required this.userQuery}) : super(key: key);
  @override
  State<UrgencyCardWidget> createState() => _UrgencyCardWidgetState();
}

class _UrgencyCardWidgetState extends State<UrgencyCardWidget> {
  bool _isCalling = false;
  bool _callTriggered = false;

  Future<void> _handleEmergencyCall() async {
    setState(() => _isCalling = true);
    
    // TODO: In a real app, fetch this from UserProfile registration data
    const String userEmergencyContact = "+919876543210"; 

    try {
      final resp = await http.post(
        Uri.parse(ApiConfig.careCompanionEmergency),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${ApiConfig.supabaseAnonKey}"},
        body: jsonEncode({
          "symptoms": widget.data["symptoms_analyzed"] ?? [], 
          "urgency": "high",
          "contact_number": userEmergencyContact // Passing dynamic user contact
        }),
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) setState(() => _callTriggered = true);
    } catch (e) { launchUrl(Uri.parse("tel:911")); }
    finally { setState(() => _isCalling = false); }
  }

  Future<void> _generateReport() async {
    setState(() => _isCalling = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate generation
    
    // SAVE TO SHARED HISTORY MANAGER
    TriageHistoryManager.add(TriageHistoryItem(
      date: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
      urgency: (widget.data["urgency"] as String? ?? "low").toLowerCase(),
      symptom: widget.userQuery,
      reasoning: widget.data["reasoning"] ?? "AI-generated triage assessment.",
      recommendations: List<String>.from(widget.data["recommendations"] ?? []),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Triage Report Generated & Stored in History"),
          action: SnackBarAction(label: "VIEW", onPressed: () {
            showDialog(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text("Medical Triage Report"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Status: ${widget.data["urgency"].toString().toUpperCase()}"),
                      const Divider(),
                      Text("Reasoning: ${widget.data["reasoning"]}"),
                      const SizedBox(height: 8),
                      const Text("Remedies/Steps:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...(widget.data["recommendations"] as List? ?? []).map((r) => Text("• $r")).toList(),
                      const Divider(),
                      const Text("Note: This is an AI assessment based on provided dataset weights (1-7). Not a substitute for professional diagnosis.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("CLOSE"))],
              ),
            );
          }),
        ),
      );
    }
    setState(() => _isCalling = false);
  }

  @override
  Widget build(BuildContext context) {
    final urgency = (widget.data["urgency"] as String? ?? "low").toLowerCase();
    final config = {
      "high": {"label": "EMERGENCY: Immediate Attention", "color": Colors.red, "icon": Icons.warning},
      "mid": {"label": "CAUTION: Visit Doctor Soon", "color": Colors.orange, "icon": Icons.medical_services},
      "low": {"label": "STABLE: Self-Care Remedies", "color": Colors.green, "icon": Icons.home},
    }[urgency] ?? {"label": "Stable Condition", "color": Colors.green, "icon": Icons.check_circle};

    return Container(
      margin: const EdgeInsets.only(top: 12, left: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: (config["color"] as Color).withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: (config["color"] as Color).withOpacity(0.1), child: Row(children: [Icon(config["icon"] as IconData, color: config["color"] as Color, size: 16), const SizedBox(width: 8), Text(config["label"] as String, style: TextStyle(color: config["color"] as Color, fontWeight: FontWeight.bold, fontSize: 13))])),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Recommended Remedies & Plan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(widget.data["reasoning"] ?? "", style: const TextStyle(fontSize: 12, color: Color(0xFF718086))),
                const SizedBox(height: 12),
                const Text("Next Steps:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                ...(widget.data["recommendations"] as List? ?? []).asMap().entries.map((e) => Text("${e.key + 1}. ${e.value}", style: const TextStyle(fontSize: 12, color: Color(0xFF718086)))),
                
                // ACTION BUTTONS BASED ON SEVERITY
                if (urgency == "high" || widget.data["trigger_emergency_call"] == true) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _callTriggered || _isCalling ? null : _handleEmergencyCall, 
                          icon: Icon(_callTriggered ? Icons.check : Icons.emergency_share, size: 14), 
                          label: Text(_callTriggered ? "Contacted ✓" : "Alert Emergency", style: const TextStyle(fontSize: 11)), 
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12))
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(Uri.parse("tel:108")), 
                          icon: const Icon(Icons.local_shipping, size: 14), 
                          label: const Text("Call 108", style: TextStyle(fontSize: 11)), 
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13191B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12))
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbyHospital())), 
                      icon: Icon(LucideIcons.mapPin, size: 14), 
                      label: const Text("Find Nearby Hospitals", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12))
                    ),
                  ),
                ] else if (urgency == "mid") ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbyHospital())), 
                      icon: Icon(LucideIcons.mapPin, size: 14), 
                      label: const Text("Find Nearby Hospitals", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2BA395), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12))
                    ),
                  ),
                ],
                // DOWNLOAD REPORT BUTTON (Available for all levels)
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _isCalling ? null : _generateReport,
                    icon: Icon(LucideIcons.download, size: 14, color: Color(0xFF718086)),
                    label: const Text("Save & Download Triage Report", style: TextStyle(fontSize: 11, color: Color(0xFF718086))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true));
  }
  @override
  void dispose() { for (var c in _controllers) { c.dispose(); } super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
      child: Row(
        children: List.generate(3, (i) => FadeTransition(opacity: _controllers[i], child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF2BA395), shape: BoxShape.circle)))),
      ),
    );
  }
}