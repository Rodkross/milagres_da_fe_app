import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

/// Decide qual tela mostrar com base no estado de autenticação do Firebase:
/// - carregando inicialmente: splash
/// - usuário logado: tela inicial
/// - usuário deslogado: tela de login
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(user: snapshot.data!);
        }
        return LoginScreen(authService: authService);
      },
    );
  }
}

/// Tela de carregamento exibida enquanto o Firebase verifica a sessão.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              color: AppColors.goldBright,
              size: 56,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldBright),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
