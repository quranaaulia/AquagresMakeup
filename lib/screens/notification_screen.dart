import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tugasakhirtpm/models/notifikasi.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Pastel color palette - same as LoginPage
  final Color primaryPurple = const Color(0xFFB19CD9);
  final Color secondaryBlue = const Color(0xFF8EC5FC);
  final Color accentPink = const Color(0xFFE0C3FC);
  final Color softWhite = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _deleteNotification(int index) async {
    final Box<NotificationItem> notifBox = Hive.box<NotificationItem>('notifications');
    final notifs = notifBox.values.toList().reversed.toList();
    
    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple.withOpacity(0.2), accentPink.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline, color: primaryPurple, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Delete Notification'),
            ],
          ),
          content: const Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Find the original notification in the box and delete it
      final originalNotif = notifs[index];
      final allNotifs = notifBox.values.toList();
      final originalIndex = allNotifs.indexWhere((n) => 
        n.content == originalNotif.content && 
        n.timestamp == originalNotif.timestamp &&
        n.transactions == originalNotif.transactions
      );
      
      if (originalIndex != -1) {
        await notifBox.deleteAt(originalIndex);
        setState(() {});
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text("Notification deleted successfully"),
              ],
            ),
            backgroundColor: primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  void _clearAllNotifications() async {
    final Box<NotificationItem> notifBox = Hive.box<NotificationItem>('notifications');
    
    if (notifBox.isEmpty) return;

    bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.withOpacity(0.2), Colors.orange.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.clear_all, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Clear All Notifications'),
            ],
          ),
          content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Clear All', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await notifBox.clear();
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("All notifications cleared"),
            ],
          ),
          backgroundColor: primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Box<NotificationItem> notifBox = Hive.box<NotificationItem>('notifications');
    final notifs = notifBox.values.toList().reversed.toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              softWhite,
              accentPink.withOpacity(0.3),
              secondaryBlue.withOpacity(0.4),
              primaryPurple.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: primaryPurple),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryPurple, secondaryBlue],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [primaryPurple, secondaryBlue],
                              ).createShader(bounds),
                              child: const Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (notifs.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [accentPink, secondaryBlue],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${notifs.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (notifs.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.clear_all, color: Colors.red[400]),
                          onPressed: _clearAllNotifications,
                          tooltip: 'Clear All',
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Expanded(
                child: notifs.isEmpty
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryPurple.withOpacity(0.1),
                                      accentPink.withOpacity(0.1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_off_outlined,
                                  size: 64,
                                  color: primaryPurple.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [primaryPurple, secondaryBlue],
                                ).createShader(bounds),
                                child: const Text(
                                  'No notifications yet',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your notifications will appear here',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: notifs.length,
                          itemBuilder: (context, index) {
                            final notif = notifs[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    accentPink.withOpacity(0.1),
                                    secondaryBlue.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple.withOpacity(0.15),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Dismissible(
                                key: Key('notification_$index'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.red, Colors.orange],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete_sweep,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  _deleteNotification(index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [primaryPurple, secondaryBlue],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryPurple.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notif.content,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF2D3748),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    accentPink.withOpacity(0.3),
                                                    secondaryBlue.withOpacity(0.3),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "Method: ${notif.transactions.isNotEmpty ? notif.transactions : '-'}",
                                                style: TextStyle(
                                                  color: primaryPurple,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${notif.timestamp.toLocal()}'.split('.')[0],
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                        onPressed: () => _deleteNotification(index),
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}