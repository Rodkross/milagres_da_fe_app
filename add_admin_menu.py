import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

# Add import if not exists
if "import 'screens/dashboard_admin_screen.dart';" not in content:
    content = content.replace("import 'screens/perfil_screen.dart';", "import 'screens/perfil_screen.dart';\nimport 'screens/dashboard_admin_screen.dart';")

# 1. Re-add isAdmin variable in _TopBar
content = content.replace("final deptAccess = data['departmentAccess'] as String?;", "final deptAccess = data['departmentAccess'] as String?;\n                  final bool isAdmin = deptAccess == 'presidencia' || deptAccess == 'secretaria';")

# 2. Pass isAdmin to _Avatar
content = content.replace("_Avatar(user: user),", "_Avatar(user: user, isAdmin: isAdmin),")

# 3. Update _Avatar class constructor
content = content.replace("class _Avatar extends StatelessWidget {\n  const _Avatar({required this.user});\n\n  final User user;", "class _Avatar extends StatelessWidget {\n  const _Avatar({required this.user, this.isAdmin = false});\n\n  final User user;\n  final bool isAdmin;")

# 4. Insert Admin menu item in _showUserMenu
admin_menu_code = """
                if (isAdmin)
                  _buildMenuItem(
                    context,
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Painel de Administração',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardAdminScreen()),
                      );
                    },
                  ),
"""

content = content.replace("""                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Configurações',""", admin_menu_code + """                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Configurações',""")

with open('lib/main.dart', 'w') as f:
    f.write(content)

