import 'package:flutter/material.dart';
import '../../../widgets/responsive_wrapper.dart';
import '../../../widgets/theme_toggle_button.dart';

class NavBar extends StatelessWidget {
  final Function(int) onNavItemTapped;

  const NavBar({
    Key? key,
    required this.onNavItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      mobile: _MobileNavBar(onNavItemTapped: onNavItemTapped),
      desktop: _DesktopNavBar(onNavItemTapped: onNavItemTapped),
    );
  }
}

class _DesktopNavBar extends StatelessWidget {
  final Function(int) onNavItemTapped;

  const _DesktopNavBar({
    Key? key,
    required this.onNavItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LogoSection(),
          Row(
            children: [
              _NavItem(
                title: 'Home',
                index: 0,
                onTap: onNavItemTapped,
              ),
              _NavItem(
                title: 'Services',
                index: 1,
                onTap: onNavItemTapped,
              ),
              _NavItem(
                title: 'Projects',
                index: 2,
                onTap: onNavItemTapped,
              ),
              _NavItem(
                title: 'Contact',
                index: 3,
                onTap: onNavItemTapped,
              ),
              const SizedBox(width: 12),
              // Add theme toggle button
              const ThemeToggleButton(isInAppBar: true),
            ],
          )
        ],
      ),
    );
  }
}

class _MobileNavBar extends StatelessWidget {
  final Function(int) onNavItemTapped;

  const _MobileNavBar({
    Key? key,
    required this.onNavItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LogoSection(),
          Row(
            children: [
              // Add theme toggle button
              const ThemeToggleButton(isInAppBar: true),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                  _showMobileMenu(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add theme toggle button
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: ThemeToggleButton(showLabel: true),
            ),
            const Divider(),
            _MobileNavItem(
              title: 'Home',
              index: 0,
              onTap: onNavItemTapped,
              icon: Icons.home,
            ),
            _MobileNavItem(
              title: 'Services',
              index: 1,
              onTap: onNavItemTapped,
              icon: Icons.design_services,
            ),
            _MobileNavItem(
              title: 'Projects',
              index: 2,
              onTap: onNavItemTapped,
              icon: Icons.work,
            ),
            _MobileNavItem(
              title: 'Contact',
              index: 3,
              onTap: onNavItemTapped,
              icon: Icons.contact_mail,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '</>', 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'MRO',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final int index;
  final Function(int) onTap;

  const _NavItem({
    Key? key,
    required this.title,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final String title;
  final int index;
  final Function(int) onTap;
  final IconData icon;

  const _MobileNavItem({
    Key? key,
    required this.title,
    required this.index,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap(index);
      },
    );
  }
}