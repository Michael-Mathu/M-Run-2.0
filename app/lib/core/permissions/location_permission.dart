import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Requests foreground ("while using") location permission. Returns true once
/// location is granted. On a permanent denial it shows a settings overlay
/// instead of re-prompting (the OS won't show the dialog again anyway).
///
/// On a non-permanent denial the OS returns `denied` immediately on every
/// subsequent call without nagging, so a repeated `.request()` is safe to call
/// from multiple entry points (home screen, run screen).
Future<bool> ensureLocationPermission(BuildContext context, WidgetRef ref) async {
  if (await Permission.location.isGranted) return true;
  final status = await Permission.locationWhenInUse.request();
  if (status.isPermanentlyDenied) {
    if (context.mounted) showLocationDeniedOverlay(context, ref);
    return false;
  }
  if (!status.isGranted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.tr('gps_permission_required', ref.read(localeProvider))),
          action: SnackBarAction(
            label: L10n.tr('open_settings', ref.read(localeProvider)),
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
    return false;
  }
  return true;
}

/// Strava-style full-screen explanation shown when location permission is
/// permanently denied, so the user understands why it's needed and jumps
/// straight to system Settings. Reused by the home screen and the run screen.
void showLocationDeniedOverlay(BuildContext context, WidgetRef ref) {
  final locale = ref.read(localeProvider);
  final cs = Theme.of(context).colorScheme;
  final surface = Theme.of(context).dialogTheme.backgroundColor ?? cs.surface;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dlg) => Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.r24)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded, color: AppTheme.brand, size: 36),
            ),
            const SizedBox(height: AppTheme.s16),
            Text(L10n.tr('gps_required_title', locale),
                style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.s8),
            Text(L10n.tr('gps_required_body', locale),
                style: TextStyle(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.s20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(dlg).pop();
                  openAppSettings();
                },
                child: Text(L10n.tr('open_settings', locale)),
              ),
            ),
            const SizedBox(height: AppTheme.s8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(dlg).pop(),
                child: Text(L10n.tr('cancel', locale)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
