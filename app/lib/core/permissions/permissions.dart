import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> ensureLocationPermission(BuildContext context, WidgetRef ref) async {
  final status = await Permission.location.status;
  if (status.isGranted) return true;
  final result = await Permission.location.request();
  return result.isGranted;
}