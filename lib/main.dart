import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';

import 'auth_gate.dart';
import 'firebase_options.dart';
import 'models/programacao_item.dart';
import 'services/auth_service.dart';
import 'screens/cultos_screen.dart';
import 'screens/biblia_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MilagresDaFeApp());
}

/// Paleta oficial do aplicativo: azul-marinho profundo com acabamento dourado.
abstract final class AppColors {
  static const navy = Color(0xFF0B2E5B);
  static const navyDeep = Color(0xFF071E3D);
  static const navyDark = Color(0xFF051733);
  static const royal = Color(0xFF123F7B);
  static const gold = Color(0xFFC9A227);
  static const goldBright = Color(0xFFE9C46A);
  static const goldPale = Color(0xFFFBF3DC);
  static const surface = Color(0xFFF3F5F9);
  static const ink = Color(0xFF122B4B);
  static const muted = Color(0xFF6B7C93);
  static const divider = Color(0xFFE3E8F0);
}

/// Metadados estáticos usados apenas para compor a interface.
abstract final class AppInfo {
  static const appName = 'Milagres da Fé';
  static const tagline = 'Igreja Evangélica';
  static const welcome = 'Bem-vindo(a) à nossa Igreja';
  static const searchHint = 'Buscar na igreja...';
  static const userInitials = 'MD';
  static const notificationCount = '3';
}

/// Atalhos exibidos na faixa inferior do cabeçalho.
const _shortcuts = <_ShortcutData>[
  _ShortcutData('Bíblia', Icons.menu_book_outlined),
  _ShortcutData('Cultos', Icons.groups_outlined),
  _ShortcutData('Quiz', Icons.lightbulb_outline),
  _ShortcutData('Oração', Icons.favorite_border),
  _ShortcutData('Livros', Icons.auto_stories),
];

/// Escala de Serviço da tela inicial.
const _escala = <_EscalaData>[
  _EscalaData(
    role: 'Recepção e Luzes',
    name: 'João e Maria',
    icon: Icons.lightbulb_outline,
  ),
  _EscalaData(
    role: 'Aux de Altar e Oferta',
    name: 'Carlos e Ana',
    icon: Icons.volunteer_activism_outlined,
  ),
  _EscalaData(
    role: 'Mídia',
    name: 'Lucas',
    icon: Icons.computer_outlined,
  ),
  _EscalaData(
    role: 'Palavra Devocional',
    name: 'Pr. Paulo',
    icon: Icons.menu_book_outlined,
  ),
  _EscalaData(
    role: 'Palavra Ofertória',
    name: 'Pb. José',
    icon: Icons.monetization_on_outlined,
  ),
  _EscalaData(
    role: 'Pregação',
    name: 'Pr. Marcos',
    icon: Icons.mic_none_outlined,
  ),
];

final class _ShortcutData {
  const _ShortcutData(this.label, this.icon);

  final String label;
  final IconData icon;
}

final class _EscalaData {
  const _EscalaData({
    required this.role,
    required this.name,
    required this.icon,
  });

  final String role;
  final String name;
  final IconData icon;
}

class MilagresDaFeApp extends StatelessWidget {
  const MilagresDaFeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
          secondary: AppColors.gold,
        ),
        fontFamily: 'Roboto',
      ),
      home: AuthGate(authService: AuthService()),
    );
  }
}

/// Tela inicial — exibe os dados do usuário autenticado.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HomeHeader(user: user)),
          const SliverToBoxAdapter(child: _ShortcutStrip()),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _HeroBanner(items: programacaoAtual),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 32, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Escala de Serviço',
                subtitle: 'Culto de Libertação • Quinta, 19:00',
                actionLabel: 'Ver tudo',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _EscalaCard(data: _escala[index]),
                ),
                childCount: _escala.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

/// Cabeçalho azul-marinho com faixa dourada, saudação, avatar e título curvo.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navyDark, AppColors.navy, AppColors.royal],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 20),
            child: Column(
              children: [
                _TopBar(user: user),
                const SizedBox(height: 18),
                const _Divider(),
                const SizedBox(height: 18),
                const _Banner(),
                const SizedBox(height: 18),
                const _Divider(),
                const SizedBox(height: 22),
                const _HeaderVerse(),
              ],
            ),
          ),
          const _CurvedBottom(height: 44),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName?.trim();
    final greeting = (displayName != null && displayName.isNotEmpty)
        ? 'Bem-vindo(a), $displayName'
        : AppInfo.welcome;

    return Row(
      children: [
        _Avatar(user: user),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? AppInfo.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.goldBright,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _NotificationButton(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User user;

  /// Gera as iniciais a partir do nome (ou do e-mail, como fallback).
  String _initials() {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'))..removeWhere((p) => p.isEmpty);
      if (parts.length >= 2) {
        return (parts.first[0] + parts[1][0]).toUpperCase();
      }
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    final email = user.email ?? '';
    return email.isEmpty ? '?' : email[0].toUpperCase();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (shouldSignOut == true) {
      await AuthService().signOut();
    }
  }

  void _showUserMenu(BuildContext context) {
    final bool isAdmin = true; // Placeholder para permissões
    final userName = user.displayName?.isNotEmpty == true ? user.displayName! : 'Usuário';
    final userEmail = user.email ?? '';
    final hasPhoto = user.photoURL != null && user.photoURL!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Puxador
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // Cabeçalho do Menu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(color: AppColors.gold, width: 1.4),
                          image: hasPhoto
                              ? DecorationImage(
                                  image: NetworkImage(user.photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !hasPhoto
                            ? Text(
                                _initials(),
                                style: const TextStyle(
                                  color: AppColors.goldBright,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (userEmail.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                const SizedBox(height: 8),
                // Opções
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Meu Perfil',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                if (isAdmin)
                  _buildMenuItem(
                    context,
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Painel de Administração',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Configurações',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context,
                  icon: Icons.logout_outlined,
                  title: 'Sair da conta',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmSignOut(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFE57373) : Colors.white;
    final iconColor = isDestructive ? const Color(0xFFE57373) : AppColors.goldBright;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 15.5,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = user.photoURL != null && user.photoURL!.isNotEmpty;

    return GestureDetector(
      onTap: () => _showUserMenu(context),
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.gold, width: 1.4),
          image: hasPhoto
              ? DecorationImage(
                  image: NetworkImage(user.photoURL!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: !hasPhoto
            ? Text(
                _initials(),
                style: const TextStyle(
                  color: AppColors.goldBright,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              )
            : null,
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.gold, width: 1.2),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Text(
                AppInfo.notificationCount,
                style: TextStyle(
                  color: AppColors.navyDeep,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Divisória dourada que separa os blocos do cabeçalho.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(height: 1, thickness: 1, color: Color(0x33E9C46A)),
        ),
        const SizedBox(width: 14),
        Icon(
          Icons.menu_book,
          size: 18,
          color: AppColors.goldBright.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Divider(height: 1, thickness: 1, color: Color(0x33E9C46A)),
        ),
      ],
    );
  }
}

/// Faixa ilustrativa com o nome da igreja.
class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.royal, AppColors.navyDark],
        ),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppInfo.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Uma igreja da Família',
                  style: TextStyle(
                    color: AppColors.goldBright,
                    fontSize: 12.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: AppColors.goldBright, width: 1.2),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.goldBright,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Versículo do dia exibido no rodapé do cabeçalho, sobre o fundo escuro.
class _HeaderVerse extends StatelessWidget {
  const _HeaderVerse();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_quote, color: AppColors.gold, size: 20),
            SizedBox(width: 8),
            Text(
              'VERSÍCULO DO DIA',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          '"A fé é o firme fundamento das coisas que se esperam."',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.45,
            fontStyle: FontStyle.italic,
            shadows: [
              Shadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hebreus 11:1',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.goldBright,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 22),
        const Align(
          alignment: Alignment.centerRight,
          child: _GoToDevotionalLink(),
        ),
      ],
    );
  }
}

/// Atalho discreto para o devocional, em uma única linha. Hoje apenas exibe
/// um aviso; no futuro será um link direto para a tela de devocional.
class _GoToDevotionalLink extends StatelessWidget {
  const _GoToDevotionalLink();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Devocional em breve!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_forward, color: AppColors.goldBright, size: 15),
            SizedBox(width: 6),
            Text(
              'Ir para devocional',
              style: TextStyle(
                color: AppColors.goldBright,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estrutura curva que fecha o cabeçalho por baixo.
class _CurvedBottom extends StatelessWidget {
  const _CurvedBottom({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomArcClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.navyDark, AppColors.navyDark],
          ),
        ),
      ),
    );
  }
}

class _BottomArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..quadraticBezierTo(size.width / 2, -size.height * 0.45, 0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Faixa de atalhos circulares posicionada logo abaixo da curva do cabeçalho.
class _ShortcutStrip extends StatelessWidget {
  const _ShortcutStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyDark,
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_shortcuts.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 20 : 18,
                right: index == _shortcuts.length - 1 ? 20 : 0,
              ),
              child: _ShortcutItem(data: _shortcuts[index]),
            );
          }),
        ),
      ),
    );
  }
}

/// Carrossel de imagens da programação, com títulos sobrepostos.
///
/// Hoje consome [programacaoAtual] (imagens locais). Quando a programação
/// passar a vir do Firestore, basta fornecer outra lista para [items].
class _HeroBanner extends StatefulWidget {
  const _HeroBanner({required this.items});

  final List<ProgramacaoItem> items;

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  static const _autoPlayInterval = Duration(seconds: 4);

  final PageController _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.items.length < 2) return;
    _timer?.cancel();
    _timer = Timer.periodic(_autoPlayInterval, (_) {
      if (!_controller.hasClients) return;
      final next = (_currentPage + 1) % widget.items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1.72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: items.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) =>
                  _ProgramacaoSlide(item: items[index]),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: _Dots(count: items.length, activeIndex: _currentPage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide individual: imagem de fundo com título e data sobrepostos.
class _ProgramacaoSlide extends StatelessWidget {
  const _ProgramacaoSlide({required this.item});

  final ProgramacaoItem item;

  @override
  Widget build(BuildContext context) {
    final provider = item.imageProvider;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagem de fundo (local ou remota) com fallback visual.
        if (provider != null)
          Image(
            image: provider,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _SlideFallback(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const _SlideFallback(showSpinner: true);
            },
          )
        else
          const _SlideFallback(),
        // Gradiente escuro para garantir a leitura do texto sobre a imagem.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x000A0A1A), Color(0xCC051733)],
              stops: [0.45, 1.0],
            ),
          ),
        ),
        // Título e data sobrepostos na base da imagem.
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                item.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  shadows: [
                    Shadow(
                      color: Color(0x99000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.data,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.goldBright,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fundo exibido enquanto a imagem carrega ou quando ela falha.
class _SlideFallback extends StatelessWidget {
  const _SlideFallback({this.showSpinner = false});

  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyDark],
        ),
      ),
      child: showSpinner
          ? const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.goldBright,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Container(
          width: isActive ? 20 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.gold
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({required this.data});

  final _ShortcutData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (data.label == 'Cultos') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CultosScreen()),
          );
        } else if (data.label == 'Bíblia') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BibliaScreen()),
          );
        } else {
          // Placeholder para futuras telas.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${data.label} em breve!'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldPale,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(data.icon, color: AppColors.navy, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    this.subtitle,
  });

  final String title;
  final String actionLabel;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.gold),
            ],
          ),
        ),
      ],
    );
  }
}

class _EscalaCard extends StatelessWidget {
  const _EscalaCard({required this.data});

  final _EscalaData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0B2E5B),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.royal],
              ),
            ),
            child: Icon(data.icon, color: AppColors.goldBright, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Navegação inferior decorativa, apenas para compor a tela.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  static const _items = <String>['Início', 'Doações', 'Convênio', 'Perfil'];
  static const _icons = <IconData>[
    Icons.home_rounded,
    Icons.volunteer_activism_outlined,
    Icons.handshake_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.navyDeep,
        border: Border(top: BorderSide(color: Color(0x33E9C46A))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_items.length, (index) {
          final isActive = index == 0;
          final color = isActive
              ? AppColors.goldBright
              : Colors.white.withValues(alpha: 0.6);
              
          return InkWell(
            onTap: () {
              if (isActive) return; // Início já está ativo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_items[index]} em breve!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icons[index], size: 22, color: color),
                  const SizedBox(height: 5),
                  Text(
                    _items[index],
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
