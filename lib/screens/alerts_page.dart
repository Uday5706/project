import 'package:flutter/material.dart';
import 'package:oceo/providers/alerts_provider.dart';
import 'package:oceo/providers/posts_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AlertsPage extends StatefulWidget {
  final Future<String> locationFuture;
  final Function(int) onNavigateToTab;

  const AlertsPage({
    super.key,
    required this.locationFuture,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        final mostUpvotedPosts = postsProvider.mostUpvotedPosts;

        final now = DateTime.now();
        final postsTodayCount = postsProvider.posts.where((post) {
          return now.difference(post.postDate).inHours <= 24;
        }).length;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Display
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
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                "Error: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red),
                              );
                            } else {
                              return Text(
                                snapshot.data ?? "Location not found",
                                style: const TextStyle(color: Colors.black54),
                              );
                            }
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Icon(Icons.check_circle, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Consumer<AlertsProvider>(
                          builder: (context, alertsProvider, child) {
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
                                    "${alertsProvider.alerts.length}",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "Active Alerts",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
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
                                "$postsTodayCount",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Reports Today",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
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
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "98%",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Safety Score",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // PageView for Quick Actions
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
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LiveAlertsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionCard(
                          'Emergency SOS',
                          'Quick access to emergency contacts.',
                          Icons.emergency,
                          Colors.red,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmergencyScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionCard(
                          'Safety Tips',
                          'Learn how to stay safe in various situations.',
                          Icons.lightbulb_outline,
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SafetyTipsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // PageView Indicator Dots
                  _buildPageIndicator(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Most Upvoted Posts Section
                  const Text(
                    'Most Upvoted Reports',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...mostUpvotedPosts
                      .take(10)
                      .map(
                        (post) => PostWidget(
                          post: post,
                          onUpvote: () {
                            postsProvider.upvotePost(post.postId);
                          },
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
        );
      },
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
          side: BorderSide(
            color: color.withAlpha(70), // Set your desired border color
            width: 1.0, // Set your desired border width
          ),
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

// Live Alerts Screen
class LiveAlertsScreen extends StatefulWidget {
  const LiveAlertsScreen({super.key});

  @override
  State<LiveAlertsScreen> createState() => _LiveAlertsScreenState();
}

class _LiveAlertsScreenState extends State<LiveAlertsScreen> {
  // We'll store the locations here to prevent re-fetching on each build
  Map<String, Future<String>> _locationFutures = {};

  @override
  void initState() {
    super.initState();
    _fetchLocationsForAlerts();
  }

  // Refetched locations on rebuild, so we should always call this.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchLocationsForAlerts();
  }

  void _fetchLocationsForAlerts() {
    final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
    for (final alert in alertsProvider.alerts) {
      if (!_locationFutures.containsKey(alert.alertId)) {
        _locationFutures[alert.alertId] = alertsProvider.fetchLocationName(
          alert.alertId,
          alert.location,
        );
      }
    }
  }

  void _showSafetyTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Safety Tips'),
          content: const Text(
            'This is where you would find specific safety tips related to the selected hazard.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, alertsProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Live Alerts'),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alertsProvider.alerts.length,
            itemBuilder: (context, index) {
              final alert = alertsProvider.alerts[index];
              Color severityColor;
              IconData severityIcon;
              switch (alert.severity) {
                case 'high':
                  severityColor = Colors.red.shade700;
                  severityIcon = Icons.warning_rounded;
                  break;
                case 'medium':
                  severityColor = Colors.orange.shade700;
                  severityIcon = Icons.warning_rounded;
                  break;
                case 'low':
                  severityColor = Colors.green.shade700;
                  severityIcon = Icons.info_rounded;
                  break;
                default:
                  severityColor = Colors.grey;
                  severityIcon = Icons.warning_rounded;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(severityIcon, color: severityColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            alert.typeOfHazard,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(
                              alert.severity.toUpperCase(),
                              style: TextStyle(color: severityColor),
                            ),
                            backgroundColor: severityColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Location with FutureBuilder and Shimmer
                      FutureBuilder<String>(
                        future: _locationFutures[alert.alertId],
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
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text(
                              'Location: Unknown',
                              style: TextStyle(color: Colors.grey.shade600),
                            );
                          } else {
                            return Text(
                              'Location: ${snapshot.data!}',
                              style: TextStyle(color: Colors.grey.shade600),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(alert.description),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _showSafetyTipsDialog(context);
                            },
                            icon: const Icon(Icons.shield_outlined),
                            label: const Text('Safety Tips'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Placeholder for share functionality
                            },
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Share Alert'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Emergency Contacts Screen
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
              onTap: () {
                // Placeholder for phone call functionality
              },
            ),
          );
        },
      ),
    );
  }
}

// Safety Tips Screen
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

// Post model and PostWidget have been moved to separate files.
class PostWidget extends StatefulWidget {
  final Post post;
  final VoidCallback onUpvote;

  const PostWidget({super.key, required this.post, required this.onUpvote});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  PageController? _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaUrls.isNotEmpty) {
      _pageController = PageController();
      _pageController!.addListener(() {
        if (_pageController!.page != null) {
          setState(() {
            _currentPage = _pageController!.page!.round();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Widget _buildMediaIndicator() {
    if (widget.post.mediaUrls.length <= 1) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.post.mediaUrls.length, (index) {
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

  String _formatPostTime(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Pic and User Info
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.post.userPic),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text(
                    _formatPostTime(widget.post.postDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: widget.onUpvote,
                child: Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.upvotes}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Post Text
          Text(widget.post.text, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          // Media (Images/Videos) and its indicator
          if (widget.post.mediaUrls.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.post.mediaUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(
                                  widget.post.mediaUrls[index],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                      // Left Arrow Button
                      if (widget.post.mediaUrls.length > 1 && _currentPage > 0)
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _pageController?.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      // Right Arrow Button
                      if (widget.post.mediaUrls.length > 1 &&
                          _currentPage < widget.post.mediaUrls.length - 1)
                        Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _pageController?.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Media Indicator Dots
                _buildMediaIndicator(),
              ],
            ),
        ],
      ),
    );
  }
}
