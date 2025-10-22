import 'package:flutter/material.dart';
import '../widgets/top_menu.dart';
import '../widgets/footer_menu.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final int currentIndex;
  final Widget child;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;

  final Function(int) onTabSelected;

  const MainLayout({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.child,
    required this.onTabSelected,
    this.onProfile, // <-- paramètre optionnel ajouté
    this.onLogout, // <-- paramètre optionnel ajouté
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopMenu(
        title: title,
        onProfile:
            onProfile ??
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile'); // valeur par défaut
            },
        onLogout:
            onLogout ??
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/logout'); // valeur par défaut
            },
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: FooterMenu(
        currentIndex: currentIndex,
        onTabSelected: onTabSelected,
      ),
    );
  }
}
