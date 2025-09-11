import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

// Data model for a single chat post
class Post {
  final String postId;
  final String username;
  final String userPic;
  final DateTime postDate;
  final Location location;
  int upvotes; // upvotes can now be changed
  final String text;
  final List<String> mediaUrls;

  Post({
    required this.postId,
    required this.username,
    required this.userPic,
    required this.postDate,
    required this.location,
    required this.upvotes,
    required this.text,
    this.mediaUrls = const [],
  });
}

// In-memory data to simulate a database
final List<Post> _inMemoryPosts = [
  Post(
    postId: '1',
    username: 'TideWatcher',
    userPic: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=TW',
    location: Location(
      latitude: 34.0522,
      longitude: -118.2437,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(hours: 2)),
    upvotes: 15,
    text:
        'Found a massive plastic patch near the coast. We need to do something!',
    mediaUrls: [
      'https://via.placeholder.com/400x300/607d8b/ffffff?text=Plastic+Patch',
      'https://via.placeholder.com/400x300/2196f3/ffffff?text=Coastline+View',
    ],
  ),
  Post(
    postId: '2',
    username: 'MarineLover',
    userPic: 'https://via.placeholder.com/150/FF5733/FFFFFF?text=ML',
    location: Location(
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(hours: 4)),
    upvotes: 8,
    text:
        'Does anyone have tips for safe marine life observation? Spotted some dolphins near my boat today!',
    mediaUrls: [
      'https://via.placeholder.com/400x300/ff6f00/ffffff?text=Dolphin+1',
    ],
  ),
  Post(
    postId: '3',
    username: 'SafetyFirst',
    userPic: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=SF',
    location: Location(
      latitude: 19.0760,
      longitude: 72.8777,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(days: 1)),
    upvotes: 22,
    text:
        'Spotted an oil slick 10 miles off the shore of Mumbai. Reported to the authorities.',
    mediaUrls: [
      'https://via.placeholder.com/400x300/42a5f5/ffffff?text=Oil+Slick',
    ],
  ),
  Post(
    postId: '4',
    username: 'EcoWarrior',
    userPic: 'https://via.placeholder.com/150/009688/FFFFFF?text=EW',
    location: Location(
      latitude: -33.8688,
      longitude: 151.2093,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(days: 1)),
    upvotes: 35,
    text:
        'Working on a new clean-up device. Any engineers want to collaborate? #innovation',
    mediaUrls: [
      'https://via.placeholder.com/400x300/26a69a/ffffff?text=Sketch+1',
      'https://via.placeholder.com/400x300/80cbc4/ffffff?text=Prototype',
    ],
  ),
  Post(
    postId: '5',
    username: 'Beachcomber',
    userPic: 'https://via.placeholder.com/150/E91E63/FFFFFF?text=BC',
    location: Location(
      latitude: 35.6895,
      longitude: 139.6917,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(days: 2)),
    upvotes: 18,
    text:
        'A beautiful day at the beach, but saw some trash. Reminder to always take your litter with you!',
    mediaUrls: [
      'https://via.placeholder.com/400x300/c5e1a5/ffffff?text=Beach+View',
    ],
  ),
  Post(
    postId: '6',
    username: 'OceanCurrents',
    userPic: 'https://via.placeholder.com/150/80DEEA/FFFFFF?text=OC',
    location: Location(
      latitude: 51.5074,
      longitude: -0.1278,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(hours: 6)),
    upvotes: 10,
    text:
        'Studying new ocean currents. The data from our latest probe is fascinating.',
    mediaUrls: [],
  ),
  Post(
    postId: '7',
    username: 'CoralGuard',
    userPic: 'https://via.placeholder.com/150/F06292/FFFFFF?text=CG',
    location: Location(
      latitude: -25.2744,
      longitude: 133.7751,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(hours: 12)),
    upvotes: 45,
    text:
        'A sad sight: coral bleaching is accelerating. We must protect our reefs!',
    mediaUrls: [
      'https://via.placeholder.com/400x300/F06292/ffffff?text=Coral+Bleaching',
      'https://via.placeholder.com/400x300/81C784/ffffff?text=Healthy+Reef',
    ],
  ),
  Post(
    postId: '8',
    username: 'FishingReport',
    userPic: 'https://via.placeholder.com/150/795548/FFFFFF?text=FR',
    location: Location(
      latitude: 25.7617,
      longitude: -80.1918,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(hours: 3)),
    upvotes: 7,
    text:
        'Great catch today! Remember to follow sustainable fishing guidelines.',
    mediaUrls: [
      'https://via.placeholder.com/400x300/795548/ffffff?text=Todays+Catch',
    ],
  ),
  Post(
    postId: '9',
    username: 'WaveRider',
    userPic: 'https://via.placeholder.com/150/66BB6A/FFFFFF?text=WR',
    location: Location(
      latitude: 34.0522,
      longitude: -118.2437,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(hours: 15)),
    upvotes: 30,
    text: 'Epic waves today! The ocean is giving us a show!',
    mediaUrls: [
      'https://via.placeholder.com/400x300/66BB6A/ffffff?text=Epic+Waves',
    ],
  ),
  Post(
    postId: '10',
    username: 'PollutionPatrol',
    userPic: 'https://via.placeholder.com/150/BDBDBD/FFFFFF?text=PP',
    location: Location(
      latitude: 38.9072,
      longitude: -77.0369,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(days: 2)),
    upvotes: 50,
    text:
        'Organizing a beach cleanup event this weekend. All hands on deck! #Cleanup',
    mediaUrls: [
      'https://via.placeholder.com/400x300/9E9E9E/ffffff?text=Volunteers',
      'https://via.placeholder.com/400x300/757575/ffffff?text=Clean+Beach',
    ],
  ),
  Post(
    postId: '11',
    username: 'SunSeeker',
    userPic: 'https://via.placeholder.com/150/FBC02D/FFFFFF?text=SS',
    location: Location(
      latitude: 34.0522,
      longitude: -118.2437,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(hours: 5)),
    upvotes: 60,
    text: 'The sunset over the water was absolutely beautiful today!',
    mediaUrls: [
      'https://via.placeholder.com/400x300/FBC02D/ffffff?text=Sunset',
    ],
  ),
  Post(
    postId: '12',
    username: 'DeepDiver',
    userPic: 'https://via.placeholder.com/150/8D6E63/FFFFFF?text=DD',
    location: Location(
      latitude: 34.0522,
      longitude: -118.2437,
      timestamp: DateTime.now(),
    ),
    postDate: DateTime.now().subtract(const Duration(hours: 8)),
    upvotes: 48,
    text: 'Discovered a new species of fish while exploring a sunken ship!',
    mediaUrls: [
      'https://via.placeholder.com/400x300/8D6E63/ffffff?text=New+Species',
      'https://via.placeholder.com/400x300/5D4037/ffffff?text=Sunken+Ship',
    ],
  ),
];

// This class simulates a database service.
// In a real app, you would connect to a backend here.
class DatabaseService {
  Future<List<Post>> getPosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _inMemoryPosts;
  }

  Future<void> addPost(Post newPost) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _inMemoryPosts.insert(0, newPost);
  }

  Future<void> updatePostUpvotes(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final post = _inMemoryPosts.firstWhere((p) => p.postId == postId);
      post.upvotes++;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating post: $e');
      }
    }
  }
}

// This is the core state management class.
class PostsProvider with ChangeNotifier {
  final _databaseService = DatabaseService();
  List<Post> _posts = [];

  PostsProvider() {
    fetchPosts();
  }

  List<Post> get posts => _posts;

  // This is a special getter to provide the list sorted by upvotes
  List<Post> get mostUpvotedPosts {
    return _posts.where((p) => p.upvotes > 0).toList()
      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));
  }

  Future<void> fetchPosts() async {
    _posts = await _databaseService.getPosts();
    notifyListeners();
  }

  Future<void> addPost(Post newPost) async {
    await _databaseService.addPost(newPost);
    await fetchPosts();
  }

  Future<void> upvotePost(String postId) async {
    await _databaseService.updatePostUpvotes(postId);
    await fetchPosts();
  }
}
