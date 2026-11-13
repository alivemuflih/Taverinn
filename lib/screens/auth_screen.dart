import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        (!isLogin && usernameController.text.trim().isEmpty)) {
      showSnack('Lengkapi semua field.');
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
          showSnack('Registrasi berhasil. Jika email confirmation aktif, cek email.');
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
      showSnack(e.message);
    } catch (e) {
      showSnack('Terjadi kesalahan: $e');
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
                    const Icon(Icons.sports_esports, size: 60),
                    const SizedBox(height: 12),
                    Text(
                      'Taverinn',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Text('Cari teman mabar tanpa ribet.'),
                    const SizedBox(height: 28),
                    if (!isLogin) ...[
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading ? null : submit,
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isLogin ? 'Login' : 'Register'),
                      ),
                    ),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin
                            ? 'Belum punya akun? Register'
                            : 'Sudah punya akun? Login',
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
