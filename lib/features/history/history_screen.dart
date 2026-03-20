import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Journal')),
      body: const Center(
        child: Text('Home / History — coming in Milestone 4'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.checkIn),
        icon: const Icon(Icons.add),
        label: const Text('Check in'),
      ),
    );
  }
}
