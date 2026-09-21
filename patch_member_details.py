with open('lib/screens/member_details_screen.dart', 'r') as f:
    content = f.read()

old_dropdown = """                    items: const [
                      DropdownMenuItem(value: 'Visitante', child: Text('Visitante')),
                      DropdownMenuItem(value: 'Membro', child: Text('Membro')),
                      DropdownMenuItem(value: 'Obreiro(a)', child: Text('Obreiro(a)')),
                      DropdownMenuItem(value: 'Diácono / Diaconisa', child: Text('Diácono / Diaconisa')),
                      DropdownMenuItem(value: 'Presbítero(a)', child: Text('Presbítero(a)')),
                      DropdownMenuItem(value: 'Pastor(a)', child: Text('Pastor(a)')),
                    ],"""

new_dropdown = """                    items: const [
                      DropdownMenuItem(value: 'Visitante', child: Text('Visitante')),
                      DropdownMenuItem(value: 'Membro', child: Text('Membro')),
                      DropdownMenuItem(value: 'Obreiro', child: Text('Obreiro(a)')),
                      DropdownMenuItem(value: 'Diácono', child: Text('Diácono / Diaconisa')),
                      DropdownMenuItem(value: 'Presbítero', child: Text('Presbítero(a)')),
                      DropdownMenuItem(value: 'Pastor', child: Text('Pastor(a)')),
                    ],"""

content = content.replace(old_dropdown, new_dropdown)

with open('lib/screens/member_details_screen.dart', 'w') as f:
    f.write(content)
