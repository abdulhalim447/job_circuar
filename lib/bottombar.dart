import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: pageController,
          onPageChanged: (int v) {
            setState(() {
              index = v;
            });
          },
          children: [HomePage(), SearchPage(), FavouritePostPage(), SettingsPage()],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Color(0xFFE6051F),
        unselectedItemColor: Colors.green,
        onTap: (int v) {
          setState(() {
            index = v;
            pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My App'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
