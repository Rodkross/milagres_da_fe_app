with open('lib/main.dart', 'r') as f:
    content = f.read()

# 1. Update _Avatar definition
old_avatar = """class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User user;"""
new_avatar = """class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.isAdmin = false});

  final User user;
  final bool isAdmin;"""
content = content.replace(old_avatar, new_avatar)

# 2. Update _showUserMenu to use this.isAdmin
old_placeholder = "final bool isAdmin = true; // Placeholder para permissões"
new_placeholder = "final bool isAdmin = this.isAdmin;"
content = content.replace(old_placeholder, new_placeholder)

# 3. Update _TopBar (Move StreamBuilder to root)
old_topbar_build = """  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName?.trim();
    final firstName = displayName?.split(' ').first;
    final greeting = (firstName != null && firstName.isNotEmpty)
        ? 'Bem-vindo(a), $firstName'
        : AppInfo.welcome;

    return Row(
      children: [
        _Avatar(user: user),
        const SizedBox(width: 12),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              String titleText = greeting;
              String subtitleText = user.email ?? AppInfo.tagline;

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data != null) {
                  final eccTitle = data['ecclesiasticalTitle'] as String?;
                  final deptAccess = data['departmentAccess'] as String?;

                  if (eccTitle != null && eccTitle != 'Membro' && eccTitle != 'Visitante' && firstName != null) {
                    titleText = '$eccTitle $firstName';
                  }

                  if (deptAccess != null) {
                    subtitleText = 'Acesso: ${deptAccess.toUpperCase()}';
                  }

                  final bool isAdmin = deptAccess == 'presidencia' || deptAccess == 'secretaria';

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleText,
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
                              subtitleText,
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
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.admin_panel_settings, color: AppColors.goldBright),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DashboardAdminScreen()),
                            );
                          },
                        ),
                    ],
                  );
                }
              }

              // Fallback se não tiver dados ainda
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
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
                    subtitleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.goldBright,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        const _NotificationButton(),
      ],
    );
  }"""
new_topbar_build = """  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName?.trim();
    final firstName = displayName?.split(' ').first;
    final greeting = (firstName != null && firstName.isNotEmpty)
        ? 'Bem-vindo(a), $firstName'
        : AppInfo.welcome;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String titleText = greeting;
        String subtitleText = user.email ?? AppInfo.tagline;
        bool isAdmin = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            final eccTitle = data['ecclesiasticalTitle'] as String?;
            final deptAccess = data['departmentAccess'] as String?;
            isAdmin = (deptAccess == 'presidencia' || deptAccess == 'secretaria');

            if (eccTitle != null && eccTitle != 'Membro' && eccTitle != 'Visitante' && firstName != null) {
              titleText = '$eccTitle $firstName';
            }
            if (deptAccess != null) {
              subtitleText = 'Acesso: ${deptAccess.toUpperCase()}';
            }
          }
        }

        return Row(
          children: [
            _Avatar(user: user, isAdmin: isAdmin),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
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
                    subtitleText,
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
      },
    );
  }"""

content = content.replace(old_topbar_build, new_topbar_build)

with open('lib/main.dart', 'w') as f:
    f.write(content)
