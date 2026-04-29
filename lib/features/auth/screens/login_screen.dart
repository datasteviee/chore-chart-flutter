import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mix/mix.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants.dart';
import '../../../core/theme/chore_mix_spacing.dart';
import '../../../core/theme/chore_mix_tokens.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(Future<void> Function() fn) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await fn();
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseCard = BoxStyler()
        .color(ChoreMixTokens.colorSurface())
        .borderRadius(BorderRadiusGeometryMix.all(ChoreMixTokens.radiusLg()))
        .padding(EdgeInsetsGeometryMix.all(ChoreMixTokens.spaceLg()))
        .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.colorOutlineVariant())));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.space(ChoreMixTokens.spaceMd)),
              child: Box(
                style: baseCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Chore Chart',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: context.space(ChoreMixTokens.spaceSm)),
                    Text(
                      'Mit E-Mail anmelden oder registrieren.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (ChoreEnv.supabaseAnonKey.isEmpty) ...[
                      SizedBox(height: context.space(ChoreMixTokens.spaceMd)),
                      Text(
                        'SUPABASE_ANON_KEY fehlt (siehe /setup).',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    SizedBox(height: context.space(ChoreMixTokens.spaceLg)),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'E-Mail'),
                    ),
                    SizedBox(height: context.space(ChoreMixTokens.spaceMd)),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Passwort'),
                    ),
                    if (_error != null) ...[
                      SizedBox(height: context.space(ChoreMixTokens.spaceMd)),
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    SizedBox(height: context.space(ChoreMixTokens.spaceLg)),
                    FilledButton(
                      onPressed: _busy || ChoreEnv.supabaseAnonKey.isEmpty
                          ? null
                          : () => _submit(() async {
                                await Supabase.instance.client.auth.signInWithPassword(
                                  email: _email.text.trim(),
                                  password: _password.text,
                                );
                              }),
                      child: _busy ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Anmelden'),
                    ),
                    SizedBox(height: context.space(ChoreMixTokens.spaceSm)),
                    OutlinedButton(
                      onPressed: _busy || ChoreEnv.supabaseAnonKey.isEmpty
                          ? null
                          : () => _submit(() async {
                                await Supabase.instance.client.auth.signUp(
                                  email: _email.text.trim(),
                                  password: _password.text,
                                );
                              }),
                      child: const Text('Registrieren'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
