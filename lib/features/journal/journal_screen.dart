import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key, required this.dateString});

  final String dateString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Journal — $dateString')),
      body: const Center(
        child: Text('Journal entry — coming in Milestone 3'),
      ),
    );
  }
}
