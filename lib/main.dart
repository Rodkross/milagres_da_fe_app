import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
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
  _ShortcutData('Cultos', Icons.church_outlined),
  _ShortcutData('Devocional', Icons.wb_sunny_outlined),
  _ShortcutData('Oração', Icons.favorite_border),
  _ShortcutData('Dízimos', Icons.volunteer_activism_outlined),
];

/// Cartões da seção "Novidades" da tela inicial.
const _news = <_NewsData>[
  _NewsData(
    title: 'Semana de Avivamento',
    excerpt: 'Cultos especiais toda noite, com louvor e pregação da Palavra.',
    date: '12 Jun',
    icon: Icons.local_fire_department_outlined,
  ),
  _NewsData(
    title: 'Grupo de Jovens',
    excerpt: 'Encontro semanal toda quinta-feira às 19h30 no templo.',
    date: '05 Jun',
    icon: Icons.favorite_outline,
  ),
  _NewsData(
    title: 'Escola Bíblica Dominical',
    excerpt: 'Inscrições abertas para as novas turmas de estudo da Bíblia.',
    date: '28 Mai',
    icon: Icons.diversity_1_outlined,
  ),
];

final class _ShortcutData {
  const _ShortcutData(this.label, this.icon);

  final String label;
  final IconData icon;
}

final class _NewsData {
  const _NewsData({
    required this.title,
    required this.excerpt,
    required this.date,
    required this.icon,
  });

  final String title;
  final String excerpt;
  final String date;
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
      home: const HomeScreen(),
    );
  }
}

/// Tela inicial — apenas composição visual, sem navegação nem integrações.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _HomeHeader()),
          const SliverToBoxAdapter(child: _ShortcutStrip()),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(child: _SearchField()),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _HeroBanner(),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _VerseCard(),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 32, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Novidades',
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
                  child: _NewsCard(data: _news[index]),
                ),
                childCount: _news.length,
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
  const _HomeHeader();

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
                const _TopBar(),
                const SizedBox(height: 18),
                const _Divider(),
                const SizedBox(height: 18),
                const _Banner(),
                const SizedBox(height: 18),
                const _Divider(),
                const SizedBox(height: 22),
                const _HeaderTitle(),
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
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _Avatar(),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppInfo.welcome,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                AppInfo.tagline,
                style: TextStyle(
                  color: AppColors.goldBright,
                  fontSize: 12,
                  letterSpacing: 0.6,
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
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.gold, width: 1.4),
      ),
      child: const Text(
        AppInfo.userInitials,
        style: TextStyle(
          color: AppColors.goldBright,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
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
        const Expanded(child: Divider(height: 1, thickness: 1, color: Color(0x33E9C46A))),
        const SizedBox(width: 14),
        Icon(Icons.church, size: 18, color: AppColors.goldBright.withValues(alpha: 0.9)),
        const SizedBox(width: 14),
        const Expanded(child: Divider(height: 1, thickness: 1, color: Color(0x33E9C46A))),
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
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fé, devoção e comunidade',
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
              Icons.church_outlined,
              color: AppColors.goldBright,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Título central com ornamento dourado, posicionado sobre a curva.
class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Ornament(),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                AppInfo.appName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  shadows: [Shadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 3))],
                ),
              ),
            ),
            SizedBox(width: 12),
            _Ornament(),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Uma igreja da Família',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Juntos somos mais fortes',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12.5),
        ),
      ],
    );
  }
}

class _Ornament extends StatelessWidget {
  const _Ornament();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gold, width: 1.4),
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
      padding: const EdgeInsets.only(top: 2, bottom: 18),
      child: SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _shortcuts.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(width: 18),
          itemBuilder: (BuildContext context, int index) =>
              _ShortcutItem(data: _shortcuts[index]),
        ),
      ),
    );
  }
}

/// Campo de busca apenas visual (não realiza pesquisa).
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B2E5B),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: AppColors.muted, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              AppInfo.searchHint,
              style: TextStyle(color: AppColors.muted, fontSize: 14.5),
            ),
          ),
          Icon(Icons.qr_code_scanner, color: AppColors.muted, size: 22),
        ],
      ),
    );
  }
}

/// Banners principais em formato de carrossel estático.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.72,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.navyDark],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x260B2E5B),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              bottom: -22,
              child: Icon(
                Icons.auto_awesome,
                size: 132,
                color: AppColors.gold.withValues(alpha: 0.14),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 104,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.goldBright, AppColors.gold],
                    ),
                  ),
                  child: const Icon(
                    Icons.church_outlined,
                    size: 44,
                    color: AppColors.navyDeep,
                  ),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEMANA DE\nAVIVAMENTO',
                        maxLines: 3,
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 20,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '12 de junho • Cultos especiais',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(child: _Dots(count: 3, activeIndex: 0)),
            ),
          ],
        ),
      ),
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
            color: isActive ? AppColors.gold : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Versículo do dia, também apenas visual.
class _VerseCard extends StatelessWidget {
  const _VerseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_quote, color: AppColors.gold, size: 22),
              SizedBox(width: 8),
              Text(
                'Versículo do dia',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '"A fé é o firme fundamento das coisas que se esperam."',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              height: 1.45,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hebreus 11:1',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({required this.data});

  final _ShortcutData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
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
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.data});

  final _NewsData data;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.royal],
              ),
            ),
            child: Icon(data.icon, color: AppColors.goldBright, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      data.date,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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

  static const _items = <String>['Início', 'Agenda', 'Doações', 'Perfil'];
  static const _icons = <IconData>[
    Icons.home_rounded,
    Icons.event_note_outlined,
    Icons.volunteer_activism_outlined,
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
          final color = isActive ? AppColors.goldBright : Colors.white.withValues(alpha: 0.6);
          return Column(
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
          );
        }),
      ),
    );
  }
}
