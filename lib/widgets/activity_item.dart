import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {

  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color color;

  const ActivityItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.12),
          child: Icon(icon, color: color),
        ),

        title: Text(title),

        subtitle: Text(subtitle),

        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}