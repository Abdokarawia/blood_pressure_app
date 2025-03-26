import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class NotificationsScreen extends StatefulWidget {
  final AnimationController animationController;

  const NotificationsScreen({
    super.key,
    required this.animationController
  });

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _healthAlertsEnabled = true;
  bool _reminderNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notifications Header
          AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) {
              return Opacity(
                opacity: widget.animationController.value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - widget.animationController.value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(10, isSmallScreen ? 10 : 10, 20, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.withOpacity(0.2),
                    const Color(0xFFE0F2F1).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.notification,
                      color: Colors.amber.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        Text(
                          'Manage your health alerts',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notification List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildNotificationCard(
                  icon: Iconsax.health,
                  title: 'Medication Reminder',
                  subtitle: 'Take your daily medication',
                  time: '10 mins ago',
                  isRead: false,
                ),
                _buildNotificationCard(
                  icon: Iconsax.activity,
                  title: 'Health Check',
                  subtitle: 'Your weekly health summary is ready',
                  time: '2 hours ago',
                  isRead: true,
                ),
                _buildNotificationCard(
                  icon: Iconsax.clock,
                  title: 'Appointment Reminder',
                  subtitle: 'Dr. Johnson - Tomorrow at 2 PM',
                  time: 'Yesterday',
                  isRead: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    bool isRead = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[100] : Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isRead ? Colors.grey[200] : Colors.amber.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isRead ? Colors.grey : Colors.amber.shade700,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isRead ? Colors.grey[700] : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: isRead ? Colors.grey[600] : Colors.black87,
          ),
        ),
        trailing: Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

}