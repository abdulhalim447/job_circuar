import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_circular/screens/favouritepostpage.dart';
import 'package:job_circular/screens/searchpage.dart';
import 'package:job_circular/screens/homepage.dart';
import 'package:job_circular/screens/settingspage.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  int index = 0;

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  color: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset(
                        'img/logo.jpg',
                        height: 30,
                        width: 30,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.app_shortcut,
                            color: Colors.white,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'অ্যাপ বন্ধ করুন!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Container(
                  color: const Color(0xFFF3E5F5), // Light purple/lavender
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'সম্মানিত চাকরি প্রত্যাশী, আপনি কি অ্যাপ থেকে বের হতে চাচ্ছেন?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // No button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('না'),
                          ),
                          // Yes button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              SystemNavigator.pop();
                            },
                            icon: const Icon(Icons.exit_to_app, size: 18),
                            label: const Text('হ্যাঁ'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        if (index == 0) {
          _showExitDialog(context);
        } else {
          setState(() {
            index = 0;
          });
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: PageView(
            controller: pageController,
            onPageChanged: (int v) {
              setState(() {
                index = v;
              });
            },
            children: const [
              HomePage(),
              SearchPage(),
              FavouritePostPage(),
              SettingsPage(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          selectedItemColor: const Color(0xFFE6051F),
          unselectedItemColor: Colors.green,
          onTap: (int v) {
            setState(() {
              index = v;
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'My App',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
