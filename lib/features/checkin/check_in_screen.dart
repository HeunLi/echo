import 'package:flutter/material.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How are you feeling?')),
      body: const Center(
        child: Text('Check-in — coming in Milestone 2'),
      ),
    );
  }
}
