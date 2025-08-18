import 'package:flutter/material.dart';
import 'package:test_app_ui/widgets/unreal_engine.dart';

/// Flutter code sample for [NavigationRail].

void main() => runApp(const NavigationRailExampleApp());

class NavigationRailExampleApp extends StatelessWidget {
  const NavigationRailExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          background: Color(0xFF0F1115), // near-black app bg
          surface: Color(0xFF12151A),    // panels / header
          primary: Color(0xFF2E95FF),    // Epic-like blue accent
          secondary: Color(0xFF2E95FF),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1115),
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
  double groupAlignment = -1.0;

  bool _railExpanded = true;

  // Add a list of widgets for the main content
  final List<Widget> _mainContents = const [
    // Unreal Engine only
    UnrealEngine(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = 0; // only one tab (Unreal Engine)
                });
              },
              // Ensure labelType is none when extended to satisfy assertion
              labelType: _railExpanded
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              backgroundColor: const Color(0xFF0A0C10), // darker left rail
              extended: _railExpanded,
              minExtendedWidth: 220,
              indicatorColor: cs.primary.withOpacity(0.18),
              selectedIconTheme: IconThemeData(color: cs.primary, size: 24),
              unselectedIconTheme:
                  const IconThemeData(color: Color(0xFF9AA4AF), size: 24),
              selectedLabelTextStyle: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Color(0xFFB7C0CA),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: _railExpanded
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          if (_railExpanded)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'EPIC',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          IconButton(
                            tooltip: _railExpanded ? 'Collapse' : 'Expand',
                            icon: Icon(
                              _railExpanded
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _railExpanded = !_railExpanded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: _railExpanded
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircleAvatar(
                            radius: 16,
                            child: Text('JD', style: TextStyle(fontSize: 12)),
                          ),
                          SizedBox(height: 8),
                          Text('Signed In', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    : const CircleAvatar(radius: 16, child: Text('JD')),
              ),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_border),
                  selectedIcon: Icon(Icons.bookmark),
                  label: Text('Unreal Engine'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(
              child: Column(
                children: [
                  // Top header bar (Epic-like)
                  // Container(
                  //   height: 56,
                  //   color: Theme.of(context).colorScheme.surface,
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   child: Row(
                  //     children: const [
                  //       // Text(
                  //       //   'Unreal Engine',
                  //       //   style: TextStyle(
                  //       //     fontSize: 18,
                  //       //     fontWeight: FontWeight.w700,
                  //       //   ),
                  //       // ),
                  //       // Spacer(),
                  //     ],
                  //   ),
                  // ),
                  // Content area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x11182532),
                            Color(0x000F1115),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: const Color(0xFF12151A),
                          child: _mainContents[_selectedIndex],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
