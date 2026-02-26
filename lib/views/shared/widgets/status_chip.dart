import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool small;

  const StatusChip({super.key, required this.status, this.small = false});

  Color getColor(String status) {
    switch (status.toLowerCase()) {
      case 'à faire':
        return Colors.grey;
      case 'en cours':
        return Colors.orange;
      case 'terminé':
        return Colors.green;
      case 'archivé':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          fontSize: small ? 10 : 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: getColor(status),
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      visualDensity: small ? VisualDensity.compact : VisualDensity.standard,
    );
  }
}
