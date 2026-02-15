import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/video_call_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/doctor_session.dart';

class DoctorChatDetail extends StatefulWidget {
  final String name;
  final String initials;
  final bool isOnline;
  final int? appointmentId;
  final int? patientId; // Added to link with real backend chat

  const DoctorChatDetail({
    Key? key,
    required this.name,
    required this.initials,
    required this.isOnline,
    this.appointmentId,
    this.patientId,
  }) : super(key: key);

  @override
  State<DoctorChatDetail> createState() => _DoctorChatDetailState();
}

class _DoctorChatDetailState extends State<DoctorChatDetail> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> messages = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    
    // Polling for new messages from patient
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages();
    });
  }

  Future<void> _fetchMessages() async {
    final docId = DoctorSession().doctorId;
    if (docId == null || widget.patientId == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/messages/${widget.patientId}/${docId}"),
        headers: {"Authorization": "Bearer ${DoctorSession().token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            messages = data.map((json) {
              return ChatMessage(
                text: json['content'] ?? '',
                isDoctor: !(json['isUserSender'] ?? true),
                time: "Now", // In a real app, parse the DB timestamp
              );
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final text = _messageController.text.trim();
    final docId = DoctorSession().doctorId;
    final patId = widget.patientId;

    _messageController.clear();

    // Optimistic Update
    setState(() {
      messages.add(ChatMessage(
        text: text,
        isDoctor: true,
        time: _getCurrentTime(),
      ));
    });

    if (docId != null && patId != null) {
      try {
        await http.post(
          Uri.parse("${ApiConfig.baseUrl}/messages/send"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${DoctorSession().token}"
          },
          body: jsonEncode({
            "userId": patId,
            "doctorId": docId,
            "content": text,
            "isUserSender": false // Doctor is the sender
          }),
        );
      } catch (e) {
        debugPrint("Error sending message: $e");
      }
    }
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final maxWidth = isDesktop ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildChatBubble(message);
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                    Text(widget.isOnline ? 'Online' : 'Offline', style: TextStyle(fontSize: 14, color: widget.isOnline ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E))),
                  ],
                ),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.phone, color: Colors.black, size: 20),
                onPressed: () {
                  final channelName = 'appointment-${widget.appointmentId ?? 0}';
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCallPage(channelName: channelName, isVideoCall: false)));
                },
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.video, color: Colors.black, size: 20),
                onPressed: () {
                  final channelName = 'appointment-${widget.appointmentId ?? 0}';
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCallPage(channelName: channelName, isVideoCall: true)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isDoctor ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: message.isDoctor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isDoctor ? const Color(0xFF199A8E) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isDoctor ? const Radius.circular(16) : Radius.zero,
                      bottomRight: message.isDoctor ? Radius.zero : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isDoctor ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(message.time, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(color: Color(0xFF199A8E), shape: BoxShape.circle),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 18),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isDoctor;
  final String time;
  ChatMessage({required this.text, required this.isDoctor, required this.time});
}
