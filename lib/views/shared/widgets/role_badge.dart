import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  final double size;

  const RoleBadge({super.key, required this.role, this.size = 12});

  Color getColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Colors.redAccent;
      case 'RESPONSABLE':
        return Colors.orangeAccent;
      case 'MEMBRE':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  String getLabel(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Admin';
      case 'RESPONSABLE':
        return 'Responsable';
      case 'MEMBRE':
        return 'Membre';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getColor(role), width: 1),
      ),
      child: Text(
        getLabel(role),
        style: TextStyle(
          color: getColor(role),
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
