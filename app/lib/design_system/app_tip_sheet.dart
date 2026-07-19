import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

Future<T?> showAppTipSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
    ),
    builder: (sheet) => Padding(
      padding: EdgeInsets.only(
        left: AppTheme.s24,
        right: AppTheme.s24,
        top: AppTheme.s24,
        bottom: AppTheme.s24 + MediaQuery.of(sheet).viewInsets.bottom,
      ),
      child: builder(sheet),
    ),
  );
}
