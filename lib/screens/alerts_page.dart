import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:oceo/providers/alerts_provider.dart';
import 'package:oceo/providers/posts_provider.dart';
import 'package:oceo/screens/chats_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

String _formatAlertTime(DateTime alertTime) {
  final now = DateTime.now();
  final difference = now.difference(alertTime);

  if (difference.inSeconds < 60) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';

  return DateFormat('MMM d').format(alertTime);
}

class AlertsPage extends StatefulWidget {
  final Future<String> locationFuture;
  final Future<LatLng> userCoordinatesFuture;
  final Function(int) onNavigateToTab;

  const AlertsPage({
    super.key,
    required this.locationFuture,
    required this.userCoordinatesFuture,
    required this.onNavigateToTab,
  });

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatPostTime(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
      future: widget.userCoordinatesFuture,
      builder: (context, userLocationSnapshot) {
        if (userLocationSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userLocationSnapshot.hasError || !userLocationSnapshot.hasData) {
          return const Center(
            child: Text("Could not determine your location."),
          );
        }

        final userLocation = userLocationSnapshot.data!;

        return Consumer2<PostsProvider, AlertsProvider>(
          builder: (context, postsProvider, alertsProvider, child) {
            final safetyScore = alertsProvider.calculateSafetyScore(
              userLocation,
            );
            final mostUpvotedPosts = postsProvider.mostUpvotedPosts;
            final now = DateTime.now();
            final postsTodayCount = postsProvider.posts
                .where((post) => now.difference(post.postDate).inHours <= 24)
                .length;

            return Scaffold(
              backgroundColor: Colors.grey.shade100,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.black54,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FutureBuilder<String>(
                              future: widget.locationFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 16.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Text(
                                    "Error: ${snapshot.error}",
                                    style: const TextStyle(color: Colors.red),
                                  );
                                }
                                return Text(
                                  snapshot.data ?? "Location not found",
                                  style: const TextStyle(color: Colors.black54),
                                );
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              count: alertsProvider.alerts.length.toString(),
                              label: "Active Alerts",
                              color: Colors.redAccent,
                            ),
                          ),
                          Expanded(
                            child: _buildSummaryCard(
                              count: postsTodayCount.toString(),
                              label: "Reports Today",
                              color: Colors.orange,
                            ),
                          ),
                          Expanded(
                            child: _buildSummaryCard(
                              count: "$safetyScore%",
                              label: "Safety Score",
                              color: _getSafetyScoreColor(safetyScore),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: PageView(
                          controller: _pageController,
                          children: <Widget>[
                            _buildQuickActionCard(
                              'Live Alerts',
                              'Get real-time updates on marine hazards.',
                              Icons.warning_rounded,
                              Colors.orange,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LiveAlertsScreen(),
                                ),
                              ),
                            ),
                            _buildQuickActionCard(
                              'Emergency SOS',
                              'Quick access to emergency contacts.',
                              Icons.emergency,
                              Colors.red,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmergencyScreen(),
                                ),
                              ),
                            ),
                            _buildQuickActionCard(
                              'Safety Tips',
                              'Learn how to stay safe in various situations.',
                              Icons.lightbulb_outline,
                              Colors.green,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SafetyTipsScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPageIndicator(),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Most Upvoted Reports',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mostUpvotedPosts.take(3).length,
                        itemBuilder: (context, index) {
                          final post = mostUpvotedPosts[index];
                          return PostWidget(
                            post: post,
                            postTimeFormatter: _formatPostTime,
                            onUpvote: () => postsProvider.toggleUpvotePost(
                              post.postId,
                              post.userId,
                            ),
                            onComment: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DiscussionScreen(post: post),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getSafetyScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    if (score >= 20) return Colors.redAccent;
    return Colors.red.shade900;
  }

  Widget _buildSummaryCard({
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: color.withAlpha(70), width: 1.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: color.withOpacity(0.1),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(subtitle, style: TextStyle(fontSize: 14, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blueAccent : Colors.grey[400],
          ),
        );
      }),
    );
  }
}

class LiveAlertsScreen extends StatelessWidget {
  const LiveAlertsScreen({super.key});

  String _formatAlertTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    return "${difference.inDays}d ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Live Alerts'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AlertsProvider>(
        builder: (context, alertsProvider, child) {
          if (alertsProvider.isLoading && alertsProvider.alerts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (alertsProvider.alerts.isEmpty) {
            return const Center(child: Text("No active alerts at the moment."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alertsProvider.alerts.length,
            itemBuilder: (context, index) {
              final alert = alertsProvider.alerts[index];
              final severity = alert.severity.toLowerCase();

              // ✅ Severity color + icon mapping
              Color severityColor;
              IconData severityIcon;
              switch (severity) {
                case 'extreme':
                  severityColor = Colors.red.shade700;
                  severityIcon = Icons.dangerous;
                  break;
                case 'severe':
                  severityColor = Colors.orange.shade700;
                  severityIcon = Icons.warning_rounded;
                  break;
                case 'moderate':
                  severityColor = Colors.yellow;
                  severityIcon = Icons.error_outline;
                  break;
                case 'low':
                default:
                  severityColor = Colors.green.shade700;
                  severityIcon = Icons.info_rounded;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(severityIcon, color: severityColor, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert.hazard,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: severityColor,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              alert.severity.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: severityColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              alert.location,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            color: Colors.grey.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatAlertTime(alert.timestamp),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(alert.description),
                      const SizedBox(height: 8),
                      Text(
                        "Coordinates: ${alert.locationCoordinates}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> emergencyContacts = [
      {
        'title': 'Emergency Services (Police, Fire, Ambulance)',
        'number': '911',
        'icon': Icons.local_police,
      },
      {
        'title': 'Coast Guard',
        'number': '1-800-424-8802',
        'icon': Icons.sailing,
      },
      {
        'title': 'Disaster Management Authority',
        'number': '1070',
        'icon': Icons.crisis_alert,
      },
      {
        'title': 'Environmental Protection Agency',
        'number': '1-800-424-9346',
        'icon': Icons.eco,
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            child: ListTile(
              leading: Icon(
                contact['icon'] as IconData,
                color: Colors.blueAccent,
              ),
              title: Text(contact['title'] as String),
              subtitle: Text(contact['number'] as String),
              trailing: const Icon(Icons.phone),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tips = [
      {
        'title': 'Oil Spill Safety',
        'tip':
            'Do not attempt to clean up an oil spill yourself. Report it immediately to the authorities.',
      },
      {
        'title': 'Dangerous Currents',
        'tip':
            'If caught in a rip current, stay calm. Swim parallel to the shore until you are out of the current, then swim back to land.',
      },
      {
        'title': 'Water Quality',
        'tip':
            'Avoid swimming in discolored or foul-smelling water. Check local advisories before entering the water.',
      },
      {
        'title': 'Jellyfish Swarms',
        'tip':
            'If stung by a jellyfish, rinse the area with seawater and seek medical attention if symptoms persist.',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Tips'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            child: ListTile(
              title: Text(
                tip['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(tip['tip']!),
            ),
          );
        },
      ),
    );
  }
}
