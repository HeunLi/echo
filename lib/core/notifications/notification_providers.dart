import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set to true when a notification tap should open the check-in sheet.
/// HomeScreen watches this and reacts, then resets it to false.
final pendingCheckInProvider = StateProvider<bool>((ref) => false);
