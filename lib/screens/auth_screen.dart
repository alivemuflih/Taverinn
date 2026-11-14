import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/guild_motif.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool loading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        (!isLogin && usernameController.text.trim().isEmpty)) {
      showSnack(AppLocalizations.of(context).completeFields);
      return;
    }

    setState(() => loading = true);

    try {
      final auth = Supabase.instance.client.auth;

      if (isLogin) {
        await auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } else {
        final response = await auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
          data: {'username': usernameController.text.trim()},
        );

        if (response.session == null) {
          if (!mounted) return;
          showSnack(AppLocalizations.of(context).signUpEmailNotice);
          setState(() => isLogin = true);
          return;
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (mounted) showSnack(e.message);
    } catch (e) {
      if (mounted) showSnack('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const TaverinnSeal(size: 44),
                    const SizedBox(height: 12),
                    Text(
                      'Taverinn',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(strings.findPlayers),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: GuildRule(),
                    ),
                    if (!isLogin) ...[
                      TextField(
                        key: const ValueKey('auth_username_input'),
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: strings.username,
                        ),
                      ),
                      const SizedBox(height: TaverinnSpace.x3),
                    ],
                    TextField(
                      key: const ValueKey('auth_email_input'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: strings.email,
                      ),
                    ),
                    const SizedBox(height: TaverinnSpace.x3),
                    TextField(
                      key: const ValueKey('auth_password_input'),
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: strings.password,
                      ),
                    ),
                    const SizedBox(height: TaverinnSpace.x4),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey('auth_submit_button'),
                        onPressed: loading ? null : submit,
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isLogin ? strings.signIn : strings.signUp),
                      ),
                    ),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin ? strings.noAccount : strings.haveAccount,
                      ),
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
