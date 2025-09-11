import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oceo/screens/profile_page.dart';
import 'package:oceo/services/location.dart' as app_location;
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'add_post_page.dart';
import 'alerts_page.dart';
import 'chats_page.dart';
import 'map_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<String> _locationFuture;
  late Future<LatLng> _userCoordinatesFuture;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _locationFuture = _getLocationName();
    _userCoordinatesFuture = _getCoordinates();
  }

  Future<String> _getLocationName() async {
    final loc = app_location.Location();
    await loc.getCurrentLocation();
    return loc.locationName ?? "Location not found";
  }

  Future<LatLng> _getCoordinates() async {
    final loc = app_location.Location();
    await loc.getCurrentLocation();
    if (loc.latitude != null && loc.longitude != null) {
      return LatLng(loc.latitude!, loc.longitude!);
    }
    return const LatLng(37.422, -122.084);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      const ChatsPage(),
      AlertsPage(
        locationFuture: _locationFuture,
        onNavigateToTab: _onItemTapped,
      ),
      AddPostPage(onNavigateToTab: _onItemTapped),
      MapPage(userLocationFuture: _userCoordinatesFuture),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            print('Menu button pressed');
          },
        ),
        title: Text(
          "Oceo",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                print('User profile tapped');
              },
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final user = userProvider.user;
                  return CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/Luffy.jpg')
                              as ImageProvider,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(2);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        // decoration: const BoxDecoration(
        //   border: Border(top: BorderSide(color: Colors.grey, width: 2.0)),
        // ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.chat),
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.warning_amber),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.warning),
              ),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Container(width: 16, height: 16),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.map_outlined),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.map),
              ),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person),
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
