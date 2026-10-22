import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class DriverChatModal {
  static void show(
    BuildContext context, {
    String driverName = 'Solomon Tekle',
    String truckModel = 'Sinotruk HOWO 30T',
    String plateNumber = 'Plate 3-824901',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DriverChatContent(
        driverName: driverName,
        truckModel: truckModel,
        plateNumber: plateNumber,
      ),
    );
  }
}

class _DriverChatContent extends StatefulWidget {
  final String driverName;
  final String truckModel;
  final String plateNumber;

  const _DriverChatContent({
    required this.driverName,
    required this.truckModel,
    required this.plateNumber,
  });

  @override
  State<_DriverChatContent> createState() => _DriverChatContentState();
}

class _DriverChatContentState extends State<_DriverChatContent> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isDriver': true,
      'time': '05:30 AM',
      'text': 'Departed Addis Ababa Kality terminal. Transit documents signed.',
    },
    {
      'isDriver': true,
      'time': '06:45 AM',
      'text': 'Cleared Mojo Dry Port weighbridge inspection. E-seal intact.',
    },
    {
      'isDriver': false,
      'time': '07:15 AM',
      'text': 'Noted. Awash terminal has been notified for gate pass.',
    },
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'isDriver': false,
        'time': 'Just now',
        'text': text,
      });
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E293B),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.driverName,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFF4ADE80),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.truckModel} • ${widget.plateNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const Divider(color: Color(0xFF1E293B), height: 24),

            // Messages Container
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _messages.length,
                itemBuilder: (ctx, idx) {
                  final msg = _messages[idx];
                  final isDriver = msg['isDriver'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: isDriver
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          color: isDriver
                              ? const Color(0xFF1E293B)
                              : AppColors.gold,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomLeft: isDriver
                                ? const Radius.circular(2)
                                : const Radius.circular(16),
                            bottomRight: !isDriver
                                ? const Radius.circular(2)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isDriver
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg['text'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: isDriver
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['time'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                color: isDriver
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF5A4010),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Message Input
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070D18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      cursorColor: AppColors.gold,
                      decoration: InputDecoration(
                        hintText: 'Message driver Solomon...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF0F172A),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
