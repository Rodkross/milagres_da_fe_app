import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

# 1. Add photoUrl parameter to _Avatar
old_avatar = """class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.isAdmin = false});

  final User user;
  final bool isAdmin;"""
new_avatar = """class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.isAdmin = false, this.photoUrl});

  final User user;
  final bool isAdmin;
  final String? photoUrl;"""
content = content.replace(old_avatar, new_avatar)

# 2. Update _Avatar build method to use photoUrl
old_build = """  @override
  Widget build(BuildContext context) {
    final hasPhoto = user.photoURL != null && user.photoURL!.isNotEmpty;"""
new_build = """  @override
  Widget build(BuildContext context) {
    final activePhoto = photoUrl ?? user.photoURL;
    final hasPhoto = activePhoto != null && activePhoto.isNotEmpty;"""
content = content.replace(old_build, new_build)

old_network = "image: NetworkImage(user.photoURL!),"
new_network = "image: NetworkImage(activePhoto!),"
content = content.replace(old_network, new_network)

# 3. Update _TopBar to extract photoUrl and pass it
old_topbar = """        bool isAdmin = false;

        if (snapshot.hasData && snapshot.data!.exists) {"""
new_topbar = """        bool isAdmin = false;
        String? currentPhotoUrl;

        if (snapshot.hasData && snapshot.data!.exists) {"""
content = content.replace(old_topbar, new_topbar)

old_dept = """            if (deptAccess != null) {
              subtitleText = 'Acesso: ${deptAccess.toUpperCase()}';
            }
          }
        }

        return Row(
          children: [
            _Avatar(user: user, isAdmin: isAdmin),"""
new_dept = """            if (deptAccess != null) {
              subtitleText = 'Acesso: ${deptAccess.toUpperCase()}';
            }
            currentPhotoUrl = data['photoUrl'] as String?;
          }
        }

        return Row(
          children: [
            _Avatar(user: user, isAdmin: isAdmin, photoUrl: currentPhotoUrl),"""
content = content.replace(old_dept, new_dept)

# 4. Same for the Avatar in _showUserMenu
old_menu_header = """    final userName = user.displayName?.isNotEmpty == true ? user.displayName! : 'Usuário';
    final userEmail = user.email ?? '';
    final hasPhoto = user.photoURL != null && user.photoURL!.isNotEmpty;"""
new_menu_header = """    final userName = user.displayName?.isNotEmpty == true ? user.displayName! : 'Usuário';
    final userEmail = user.email ?? '';
    final activePhoto = photoUrl ?? user.photoURL;
    final hasPhoto = activePhoto != null && activePhoto.isNotEmpty;"""
content = content.replace(old_menu_header, new_menu_header)

with open('lib/main.dart', 'w') as f:
    f.write(content)
