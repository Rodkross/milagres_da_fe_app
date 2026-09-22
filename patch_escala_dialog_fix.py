with open('lib/screens/admin_escala_screen.dart', 'r') as f:
    content = f.read()

import re

old_dialog = """  void _showAddRoleDialog(BuildContext context, Map<String, dynamic> currentData) {
    String? selectedRole;
    String? selectedName;
    
    final List currentAssignments = currentData['assignments'] ?? [];"""

new_dialog = """  void _showAddRoleDialog(BuildContext context, Map<String, dynamic> currentData) {
    String? selectedRole;
    String? selectedName;
    
    // Cache the future so it doesn't re-fetch on every dropdown selection (setState)
    final _obreirosFuture = _fetchObreiros();
    
    final List currentAssignments = currentData['assignments'] ?? [];"""
content = content.replace(old_dialog, new_dialog)

old_future = """                    FutureBuilder<List<Map<String, String>>>(
                      future: _fetchObreiros(),
                      builder: (context, snapshot) {"""
new_future = """                    FutureBuilder<List<Map<String, String>>>(
                      future: _obreirosFuture,
                      builder: (context, snapshot) {"""
content = content.replace(old_future, new_future)

old_check = """                        // Garante que o item selecionado ainda exista na lista carregada
                        if (selectedName != null && !users.any((u) => u['name'] == selectedName)) {
                          selectedName = null;
                        }"""
new_check = """                        // Garante que o item selecionado ainda exista na lista carregada
                        if (selectedName != null && !users.any((u) => u['id'] == selectedName)) {
                          selectedName = null;
                        }"""
content = content.replace(old_check, new_check)

with open('lib/screens/admin_escala_screen.dart', 'w') as f:
    f.write(content)
