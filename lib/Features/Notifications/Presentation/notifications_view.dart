import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _currentUserId = user.uid;
        });
        _fetchNotifications();
      } else {
        setState(() {
          _error = "User not authenticated. Please log in.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Authentication error: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .doc(_currentUserId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = snapshot.docs.map((doc) {
        return doc.data();
      }).toList();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to fetch notifications: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> scheduleNotifications({
    required String medicationId,
    required String medicationName,
    required DateTime scheduledTime,
    required List<int> selectedDays,
    required String frequency,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30));
      final scheduledTimes = <DateTime>[];

      // Generate schedule for the next 30 days
      for (var date = now; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
        final dayOfWeek = date.weekday;
        if (!selectedDays.contains(dayOfWeek)) continue;

        final notificationTime = DateTime(
          date.year,
          date.month,
          date.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );

        if (notificationTime.isBefore(now)) continue;
        scheduledTimes.add(notificationTime);
      }

      if (scheduledTimes.isEmpty) {
        setState(() {
          _error = 'No valid notification times for this schedule';
        });
        return;
      }

      final notificationId = const Uuid().v4();
      final notificationRef = _firestore
          .collection('notifications')
          .doc(_currentUserId)
          .collection('notifications')
          .doc(notificationId);

      await notificationRef.set({
        'notificationId': notificationId,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'scheduledTimes': scheduledTimes.map((time) => Timestamp.fromDate(time)).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'frequency': frequency,
        'selectedDays': selectedDays,
        'payload': {
          'type': 'medication_reminder',
          'medicationId': medicationId,
          'action': 'take_medication',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      });

      // Subscribe to topic for this medication
      await _messaging.subscribeToTopic('medication_$medicationId');

      // Refresh notifications list
      _fetchNotifications();

    } catch (e) {
      setState(() {
        _error = 'Failed to schedule notifications: $e';
      });
    }
  }

  String _getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
    }
  }

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
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.amber.shade700,
                    ),
                    onPressed: _fetchNotifications,
                  ),
                ],
              ),
            ),
          ),

          // Content area - Shows loading, error, or notifications
          Expanded(
            child: _buildContentArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_error != null) {
      return _buildErrorState();
    } else if (_notifications.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildNotificationsList();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.amber.shade700,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your notifications...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 50,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _fetchNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Notifications Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'When you have new medication reminders or health alerts, they will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final bool isRead = notification['status'] == 'read' || notification['status'] == 'dismissed';
        String timeText = 'Unknown';

        if (notification.containsKey('createdAt') && notification['createdAt'] != null) {
          timeText = _getTimeAgo(notification['createdAt']);
        }

        IconData iconData;
        switch(notification['payload']?['type']) {
          case 'medication_reminder':
            iconData = Iconsax.health;
            break;
          case 'appointment':
            iconData = Iconsax.clock;
            break;
          case 'health_summary':
            iconData = Iconsax.activity;
            break;
          default:
            iconData = Iconsax.notification;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isRead ? Colors.grey[100] : Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Dismissible(
            key: Key(notification['notificationId']),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              // Remove from UI first
              setState(() {
                _notifications.removeAt(index);
              });

              // Then delete from database
              try {
                await _firestore
                    .collection('notifications')
                    .doc(_currentUserId)
                    .collection('notifications')
                    .doc(notification['notificationId'])
                    .delete();
              } catch (e) {
                // If delete fails, show error and refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete notification: $e')),
                );
                _fetchNotifications();
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey[200] : Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: isRead ? Colors.grey : Colors.amber.shade700,
                ),
              ),
              title: Text(
                notification['medicationName'] ?? 'Notification',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isRead ? Colors.grey[700] : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    notification['payload']?['type'] == 'medication_reminder'
                        ? 'Remember to take your medication'
                        : 'Notification',
                    style: GoogleFonts.poppins(
                      color: isRead ? Colors.grey[600] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    timeText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              trailing: isRead
                  ? null
                  : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () async {
                // Mark as read when tapped
                if (!isRead) {
                  await _firestore
                      .collection('notifications')
                      .doc(_currentUserId)
                      .collection('notifications')
                      .doc(notification['notificationId'])
                      .update({'status': 'read'});

                  // Update local state
                  setState(() {
                    _notifications[index]['status'] = 'read';
                  });
                }

                // Handle notification action
                if (notification['payload']?['type'] == 'medication_reminder') {
                  // Navigate to medication details or mark as taken
                  // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => MedicationDetailsScreen(id: notification['medicationId'])));
                }
              },
            ),
          ),
        );
      },
    );
  }
}