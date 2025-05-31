import 'package:flutter/material.dart';
import '../../domain/entities/student.dart';

class StudentListItem extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentListItem({
    super.key,
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            student.firstName[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('${student.firstName} ${student.lastName}'),
        subtitle: Text('Grade: ${student.grade}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
