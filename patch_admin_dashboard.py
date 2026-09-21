with open('lib/screens/dashboard_admin_screen.dart', 'r') as f:
    content = f.read()

# Add import
import_stmt = "import 'admin_cultos_screen.dart';"
if import_stmt not in content:
    content = content.replace("import 'convenio_screen.dart';", "import 'convenio_screen.dart';\n" + import_stmt)

# Add Card
old_card = """          _buildDashboardCard(
            context,
            title: 'Cantina / Conveniência',"""
new_card = """          _buildDashboardCard(
            context,
            title: 'Cultos / Programação',
            subtitle: 'Gerencie os cultos e eventos na tela inicial',
            icon: Icons.calendar_month_outlined,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCultosScreen()));
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            title: 'Cantina / Conveniência',"""
content = content.replace(old_card, new_card)

with open('lib/screens/dashboard_admin_screen.dart', 'w') as f:
    f.write(content)
