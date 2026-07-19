import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/network/session_provider.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isRegister = false;
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final err = _isRegister
        ? await ref.read(sessionProvider.notifier).register(_email.text.trim(), _pass.text)
        : await ref.read(sessionProvider.notifier).login(_email.text.trim(), _pass.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final locale = ref.watch(localeProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(AppTheme.r16),
                    ),
                    child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: AppTheme.s16),
                  Text(_isRegister
                      ? L10n.tr('create_account', locale)
                      : L10n.tr('sign_in', locale),
                      style: text.headlineMedium),
                  const SizedBox(height: AppTheme.s24),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: L10n.tr('email', locale),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.r12)),
                    ),
                  ),
                  const SizedBox(height: AppTheme.s12),
                  TextField(
                    controller: _pass,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: L10n.tr('password', locale),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.r12)),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppTheme.s12),
                    Text(_error!, style: text.bodySmall!.copyWith(color: AppTheme.sos)),
                  ],
                  const SizedBox(height: AppTheme.s20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.brand,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isRegister
                            ? L10n.tr('create_account', locale)
                            : L10n.tr('sign_in', locale)),
                  ),
                  const SizedBox(height: AppTheme.s12),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister
                        ? L10n.tr('have_account', locale)
                        : L10n.tr('need_account', locale)),
                  ),
                  const SizedBox(height: AppTheme.s8),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: Text(L10n.tr('continue_anonymous', locale)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
