with open('lib/screens/admin_escala_screen.dart', 'r') as f:
    content = f.read()

import re

old_dialog = """  void _showAddRoleDialog(BuildContext context, Map<String, dynamic> currentData) {
    String? selectedRole;
    String? selectedName;
    
    final roles = [
      'Altar e Oferta',
      'Luzes Recepção',
      'Som e Mídia',
      'Cantina',
      'Direção do Culto',
      'Palavra Devocional',
      'Palavra Ofertória',
      'Pregação'
    ];"""

new_dialog = """  void _showAddRoleDialog(BuildContext context, Map<String, dynamic> currentData) {
    String? selectedRole;
    String? selectedName;
    
    final List currentAssignments = currentData['assignments'] ?? [];
    final alreadyAssigned = currentAssignments.map((e) => e['role'] as String).toSet();
    
    final allRoles = [
      'Altar e Oferta',
      'Luzes Recepção',
      'Som e Mídia',
      'Cantina',
      'Direção do Culto',
      'Palavra Devocional',
      'Palavra Ofertória',
      'Pregação'
    ];
    
    final roles = allRoles.where((r) => !alreadyAssigned.contains(r)).toList();"""

content = content.replace(old_dialog, new_dialog)

# Also handle the case where `roles` is empty
old_dropdown = """                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Função'),
                      value: selectedRole,
                      items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) => setState(() => selectedRole = val),
                    ),"""
new_dropdown = """                    roles.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Todas as funções já foram preenchidas!', style: TextStyle(color: Colors.red)),
                          )
                        : DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Função'),
                            value: selectedRole,
                            items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                            onChanged: (val) => setState(() => selectedRole = val),
                          ),"""

content = content.replace(old_dropdown, new_dropdown)

with open('lib/screens/admin_escala_screen.dart', 'w') as f:
    f.write(content)
