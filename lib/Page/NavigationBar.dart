import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:warehouse_project/Page/RequestsPage.dart';
import 'package:warehouse_project/Page/ShopPage.dart';
import 'package:warehouse_project/Page/WarehousesPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    WarehousesPage(),
    RequestsPage(),
    ShopPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Адаптация для веба
    if (kIsWeb) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: onTabTapped,
              labelType: NavigationRailLabelType.selected,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Склады'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.mail),
                  label: Text('Заявки'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shop),
                  label: Text('Магазин'),
                ),
              ],
            ),
            Expanded(
              child: _children[_currentIndex],
            ),
          ],
        ),
      );
    } else {
      // Мобильная версия
      return Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              label: 'Склады',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.mail),
              label: 'Заявки',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.shop),
              label: 'Заявки',
            ),
          ],
        ),
      );
    }
  }
}
