import 'package:flutter/material.dart';
import 'package:mundo/pages/map_view.dart';
import 'package:mundo/pages/my_profile_view.dart';
import 'package:mundo/pages/search_view.dart';
import 'package:mundo/pages/select_post_location.dart';

class HomeView extends StatefulWidget{
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const MapView(),
    const SearchView(),
    const SelectPostLocationView(),
    const MyProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        ),
        unselectedIconTheme: IconThemeData(
          color: Theme.of(context).floatingActionButtonTheme.foregroundColor
        ),
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        items: const  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Suchen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Erstellen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          )
        ],
      ),
    );
  }
}