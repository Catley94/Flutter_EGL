import 'package:flutter/material.dart';
import 'package:test_app_ui/widgets/unreal_engine.dart';

/// Flutter code sample for [NavigationRail].

void main() => runApp(const NavigationRailExampleApp());

class NavigationRailExampleApp extends StatelessWidget {
  const NavigationRailExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const NavRailExample(),
    );
  }
}

class NavRailExample extends StatefulWidget {
  const NavRailExample({super.key});

  @override
  State<NavRailExample> createState() => _NavRailExampleState();
}

class _NavRailExampleState extends State<NavRailExample> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  double groupAlignment = -1.0;

  // Add a list of widgets for the main content
  final List<Widget> _mainContents = const [
    // Text('Main Content 1', style: TextStyle(fontSize: 32)),
    // Text('Main Content 2', style: TextStyle(fontSize: 32)),
    UnrealEngine(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: labelType,
              destinations: const <NavigationRailDestination>[
                // NavigationRailDestination(
                //   icon: Icon(Icons.games_outlined),
                //   selectedIcon: Icon(Icons.games),
                //   label: Text('Games'),
                // ),
                // NavigationRailDestination(
                //   icon: Icon(Icons.book_outlined),
                //   selectedIcon: Icon(Icons.book),
                //   label: Text('News'),
                // ),
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_border),
                  selectedIcon: Icon(Icons.bookmark),
                  label: Text('Unreal Engine'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(child: Center(child: _mainContents[_selectedIndex])),
          ],
        ),
      ),
    );
  }
}
