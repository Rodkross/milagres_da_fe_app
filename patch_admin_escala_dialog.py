with open('lib/screens/admin_escala_screen.dart', 'r') as f:
    content = f.read()

import re

old_dialog = """  void _showAddRoleDialog(BuildContext context, Map<String, dynamic> currentData) {
    final roleCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Serviço'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: 'Função (ex: Recepção)'),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome(s) do(s) responsável(is)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (roleCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
                
                final List assignments = currentData['assignments'] ?? [];
                assignments.add({
                  'role': roleCtrl.text.trim(),
                  'name': nameCtrl.text.trim(),
                });
                
                await FirebaseFirestore.instance.collection('escala').doc('current').set({
                  'assignments': assignments,
                }, SetOptions(merge: true));
                
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      }
    );
  }"""

new_dialog = """  Future<List<Map<String, String>>> _fetchObreiros() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final allowedTitles = [
      'Obreiro', 'Obreira', 'Obreiro(a)',
      'Diácono', 'Diaconisa', 'Diácono / Diaconisa',
      'Presbítero', 'Presbítera', 'Presbítero(a)',
      'Pastor', 'Pastora', 'Pastor(a)'
    ];
    final list = <Map<String, String>>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final title = data['ecclesiasticalTitle'] ?? '';
      if (allowedTitles.contains(title)) {
        list.add({
           'id': doc.id,
           'name': data['name'] ?? 'Sem nome',
        });
      }
    }
    list.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    return list;
  }

  void _showAddRoleDialog(BuildContext context, Map<String, dynamic> currentData) {
    String? selectedRole;
    String? selectedName;
    
    final roles = [
      'Recepção',
      'Altar e Oferta',
      'Som e Multimídia',
      'Limpeza e Organização',
      'Cantina / Conveniência',
      'Estacionamento',
      'Louvor',
      'Portaria',
      'Segurança',
      'Direção do Culto',
      'Pregação da Palavra'
    ];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Serviço'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Função'),
                      value: selectedRole,
                      items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) => setState(() => selectedRole = val),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, String>>>(
                      future: _fetchObreiros(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return const Text('Erro ao carregar lista.');
                        }
                        
                        final users = snapshot.data ?? [];
                        if (users.isEmpty) {
                          return const Text('Nenhum obreiro encontrado no sistema.', style: TextStyle(color: Colors.red));
                        }
                        
                        // Garante que o item selecionado ainda exista na lista carregada
                        if (selectedName != null && !users.any((u) => u['name'] == selectedName)) {
                          selectedName = null;
                        }

                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Responsável'),
                          value: selectedName,
                          items: users.map((u) => DropdownMenuItem(value: u['name'], child: Text(u['name'] ?? ''))).toList(),
                          onChanged: (val) => setState(() => selectedName = val),
                        );
                      }
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedRole == null || selectedName == null) return;
                    
                    final List assignments = currentData['assignments'] ?? [];
                    assignments.add({
                      'role': selectedRole,
                      'name': selectedName,
                    });
                    
                    await FirebaseFirestore.instance.collection('escala').doc('current').set({
                      'assignments': assignments,
                    }, SetOptions(merge: true));
                    
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          }
        );
      }
    );
  }"""

content = content.replace(old_dialog, new_dialog)

with open('lib/screens/admin_escala_screen.dart', 'w') as f:
    f.write(content)
