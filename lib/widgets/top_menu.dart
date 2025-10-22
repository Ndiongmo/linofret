import 'package:flutter/material.dart';

class TopMenu extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfile;
  final VoidCallback onLogout;
  final String title;

  const TopMenu({
    super.key,
    required this.title,
    required this.onProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.green.shade50,
      shadowColor: Colors.grey.withOpacity(0.2),
      titleSpacing: 0,
      automaticallyImplyLeading: false,

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🟢 Logo Linofret App
          Row(
            children: [
              const SizedBox(width: 12),
              Image.asset(
                'assets/logo.png', // 🔁 Ton logo (à placer dans assets)
                height: 36,
              ),
              const SizedBox(width: 8),
              Text(
                "Linofret", // 🔁 Le nom de ton application
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),

          // ⋮ Menu utilisateur à droite
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                onProfile();
              } else if (value == 'logout') {
                onLogout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person_outline, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Profil"),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text("Déconnexion"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
