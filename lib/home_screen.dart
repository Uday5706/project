import 'package:flutter/material.dart';
import 'package:pokepedia/services/Location.dart';
import 'package:shimmer/shimmer.dart';

import 'auto_scroll.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use a Future variable to hold the result of the async call
  late Future<String> _locationFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future here
    _locationFuture = _getLocation();
  }

  Future<String> _getLocation() async {
    final loc = Location();
    await loc.getCurrentLocation();

    return loc.locationName ?? "Location not found";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            print('Menu button pressed');
          },
        ),
        title: const Text(
          "Oceo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/Luffy.jpg'),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: double.infinity,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
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
                      future: _locationFuture,
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _locationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: double.infinity,
                              height: 100.0,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
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
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          );
                        } else {
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
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "12",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Active Alerts",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _locationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: double.infinity,
                              height: 100.0,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
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
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          );
                        } else {
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
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "142",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Reports Today",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _locationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: double.infinity,
                              height: 100.0,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
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
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          );
                        } else {
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
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ), // Wrap the AutoScrollCarousel with a SizedBox or a fixed-height Container
              Container(
                height: 150, // Set a fixed height for the carousel
                child: AutoScrollCarousel(
                  children: [
                    GestureDetector(
                      onTap: () => print("Tile 1 clicked"),
                      child: Container(
                        margin: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
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
                        child: const Text(
                          "Tile 1",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => print("Tile 2 clicked"),
                      child: Container(
                        margin: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
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

                        child: const Text(
                          "Tile 2",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => print("Tile 3 clicked"),
                      child: Container(
                        margin: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
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
                        child: const Text(
                          "Tile 3",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
