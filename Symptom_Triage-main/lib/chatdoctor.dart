import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';
import 'package:symtom_checker/video_call_page.dart';
import 'package:symtom_checker/language/app_strings.dart';

class ChatDoctorScreen extends StatefulWidget {
  final String doctorName;
  final String doctorImage;
  final String doctorStatus;
  final bool isPaid;
  final int? doctorId;
  /// Pass appointment id so video/voice use same channel (appointment-{id})
  final int? appointmentId;

  const ChatDoctorScreen({
    Key? key,
    this.doctorName = "Dr. Marcus Horizon",
    this.doctorImage = "assets/D6.jpg",
    this.doctorStatus = "Online",
    this.isPaid = false,
    this.doctorId,
    this.appointmentId,
  }) : super(key: key);

  @override
  State<ChatDoctorScreen> createState() => _ChatDoctorScreenState();
}

class _ChatDoctorScreenState extends State<ChatDoctorScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  
  List<ChatMessage> messages = [];
  Timer? _pollingTimer;
  String _appointmentStatus = 'PENDING';

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _fetchMessages();
    _fetchAppointmentStatus();
    
    // Start polling every 3 seconds for messages and status
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages();
      _fetchAppointmentStatus();
    });
  }

  Future<void> _fetchAppointmentStatus() async {
    if (widget.appointmentId == null) return;
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/appointments/${widget.appointmentId}"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _appointmentStatus = data['status'] ?? 'PENDING';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching status: $e");
    }
  }

  Future<void> _fetchMessages() async {
    final userId = UserSession().userId;
    // If no doctorId or userId, we can't fetch. Fallback to empty or mocked.
    if (userId == null || widget.doctorId == null) {
        // Fallback mock if you strictly want to show something, 
        // but better to show empty for "real" app feeling or error.
        return; 
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/messages/$userId/${widget.doctorId}"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            messages = data.map((json) {
              final bool isUser = json['isUserSender'] ?? true; 
              // timestamps logic can be added later
              return ChatMessage(
                text: json['content'] ?? '',
                isUser: isUser,
                timestamp: "Now", // Logic for time parsing
                senderName: isUser ? AppStrings.s('you_label', 'You') : widget.doctorName,
              );
            }).toList();
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _sendMessage() async {
    if (_appointmentStatus == 'COMPLETED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Consultation is completed. You cannot send more messages.")),
      );
      return;
    }
    if (_messageController.text.isNotEmpty) {
      final text = _messageController.text;
      final userId = UserSession().userId;
      
      // Optimistic Update
      setState(() {
        messages.add(ChatMessage(
          text: text,
          isUser: true,
          timestamp: "Now",
        ));
      });
      _messageController.clear();
      _scrollToBottom();

     if (userId != null && widget.doctorId != null) {
        try {
          await http.post(
             Uri.parse("${ApiConfig.baseUrl}/messages/send"),
             headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${UserSession().token}"
             },
             body: jsonEncode({
               "userId": userId,
               "doctorId": widget.doctorId,
               "content": text,
               "isUserSender": true
             })
          );
        } catch (e) {
           debugPrint("Error sending message: $e");
        }
     }
    }
  }

  void _startVideoCall() {
    if (_appointmentStatus == 'COMPLETED') {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Consultation is completed. Call disabled.")),
      );
      return;
    }
    if (!widget.isPaid) {
      _showPaymentRequiredDialog();
      return;
    }
    final channelName = 'appointment-${widget.appointmentId ?? widget.doctorId ?? 0}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallPage(
          channelName: channelName,
          isVideoCall: true,
        ),
      ),
    );
  }

  void _startVoiceCall() {
     if (_appointmentStatus == 'COMPLETED') {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Consultation is completed. Call disabled.")),
      );
      return;
    }
    if (!widget.isPaid) {
      _showPaymentRequiredDialog();
      return;
    }
    final channelName = 'appointment-${widget.appointmentId ?? widget.doctorId ?? 0}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallPage(
          channelName: channelName,
          isVideoCall: false,
        ),
      ),
    );
  }

  void   _showPaymentRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.s('payment_required', 'Payment Required')),
        content: Text(
          AppStrings.s('payment_required_desc', 'You can chat with the doctor for free. Video and Voice calls are available only after payment is confirmed.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.s('cancel', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF199A8E)),
            child: Text(AppStrings.s('ok', 'Ok'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument() async {
    try {
      await Permission.storage.request();
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      setState(() {
        messages.add(ChatMessage(text: "📄 ${result.files.single.name}", isUser: true, timestamp: "Now"));
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("File upload error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            AvatarImage(
              imageUrl: widget.doctorImage,
              width: 40,
              height: 40,
              borderRadius: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  widget.doctorStatus == 'Online' ? AppStrings.s('online_status', 'Online') : widget.doctorStatus,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const FaIcon(FontAwesomeIcons.video, size: 20, color: Colors.black), onPressed: _startVideoCall),
          IconButton(icon: const FaIcon(FontAwesomeIcons.phone, size: 20, color: Colors.black), onPressed: _startVoiceCall),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildChatBubble(messages[index]),
            ),
          ),
          _buildMessageInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser ? const Color(0xFF199A8E) : const Color(0xFFE8F5F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : Colors.black)),
        ),
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file, color: Color(0xFF199A8E)), onPressed: _uploadDocument),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
              hintText: AppStrings.s('type_message_hint', 'Type message...'),
              border: InputBorder.none,
            ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Color(0xFF199A8E)), onPressed: _sendMessage),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;
  final String? senderName;
  ChatMessage({required this.text, required this.isUser, required this.timestamp, this.senderName});
}
