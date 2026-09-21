with open('lib/screens/member_details_screen.dart', 'r') as f:
    content = f.read()

# Add import if missing
if "import 'perfil_screen.dart';" not in content:
    content = content.replace("import 'package:firebase_auth/firebase_auth.dart';", "import 'package:firebase_auth/firebase_auth.dart';\nimport 'perfil_screen.dart';")

old_buttons = """                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon("""
new_buttons = """                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerfilScreen(adminEditUserId: userDoc.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_document, size: 24),
                    label: const Text(
                      'Editar Ficha Cadastral',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon("""
content = content.replace(old_buttons, new_buttons)

with open('lib/screens/member_details_screen.dart', 'w') as f:
    f.write(content)
