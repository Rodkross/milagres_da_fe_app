with open('lib/main.dart', 'r') as f:
    content = f.read()

# I will use Python replace to cleanly replace the _TopBar class
import re
start_idx = content.find("class _TopBar extends StatelessWidget {")
end_idx = content.find("class _CurvedBottom extends StatelessWidget {")

topbar_code = """class _TopBar extends StatelessWidget {
  const _TopBar({required this.user});

  final User user;

  @override
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
          ],
        );
      },
    );
  }
}

"""

new_content = content[:start_idx] + topbar_code + content[end_idx:]

with open('lib/main.dart', 'w') as f:
    f.write(new_content)

