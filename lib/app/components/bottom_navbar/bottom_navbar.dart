import 'package:flutter/material.dart';
import 'package:moist/app/screen/pages/home.dart';
import 'package:moist/app/screen/pages/library.dart';
import 'package:moist/app/screen/pages/settings.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: const HomePage(),
          item: ItemConfig(
            icon: const Icon(Icons.home_rounded),
            title: "Home",
          ),
        ),
        PersistentTabConfig(
          screen: const LibraryPage(),
          item: ItemConfig(
            icon: const Icon(Icons.library_music_rounded),
            title: "Library",
          ),
        ),
        PersistentTabConfig(
          screen: const SettingsPage(),
          item: ItemConfig(
            icon: const Icon(Icons.settings_rounded),
            title: "Settings",
          ),
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.surface,
      stateManagement: true,
      resizeToAvoidBottomInset: false,
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }
}
