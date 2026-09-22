with open('lib/screens/admin_escala_screen.dart', 'r') as f:
    content = f.read()

import re

# We also need to import helpers.dart to resolve the title
import_stmt = "import '../helpers.dart';"
if import_stmt not in content:
    content = content.replace("import 'package:intl/intl.dart';", "import 'package:intl/intl.dart';\n" + import_stmt)

old_fetch = """  Future<List<Map<String, String>>> _fetchObreiros() async {
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
  }"""

new_fetch = """  Future<List<Map<String, String>>> _fetchObreiros() async {
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
        final gender = data['gender'] ?? 'Masculino';
        final resolvedTitle = Helpers.resolveTitle(title, gender);
        final name = data['name'] ?? 'Sem nome';
        final photoUrl = data['photoUrl'] ?? '';
        list.add({
           'id': doc.id,
           'name': name,
           'displayName': '$resolvedTitle $name',
           'photoUrl': photoUrl,
        });
      }
    }
    list.sort((a, b) => (a['displayName'] ?? '').compareTo(b['displayName'] ?? ''));
    return list;
  }"""

content = content.replace(old_fetch, new_fetch)

old_dropdown = """                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Responsável'),
                          value: selectedName,
                          items: users.map((u) => DropdownMenuItem(value: u['name'], child: Text(u['name'] ?? ''))).toList(),
                          onChanged: (val) => setState(() => selectedName = val),
                        );"""
new_dropdown = """                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Responsável'),
                          value: selectedName,
                          items: users.map((u) {
                            return DropdownMenuItem(
                              value: u['id'], // usamos ID para pegar os dados depois
                              child: Row(
                                children: [
                                  if (u['photoUrl']!.isNotEmpty) ...[
                                    CircleAvatar(radius: 12, backgroundImage: NetworkImage(u['photoUrl']!)),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(child: Text(u['displayName'] ?? '', overflow: TextOverflow.ellipsis)),
                                ],
                              )
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selectedName = val),
                        );"""

content = content.replace(old_dropdown, new_dropdown)

old_save = """                ElevatedButton(
                  onPressed: () async {
                    if (selectedRole == null || selectedName == null) return;
                    
                    final List assignments = currentData['assignments'] ?? [];
                    assignments.add({
                      'role': selectedRole,
                      'name': selectedName,
                    });"""

new_save = """                ElevatedButton(
                  onPressed: () async {
                    if (selectedRole == null || selectedName == null) return;
                    
                    // selectedName is the ID now. We need to find the user in the DOM, wait we can't easily here without passing it.
                    // Oh, we are in a StatefulBuilder, but we can't access the list directly if we don't store it globally.
                    // Wait, we can fetch it again or store it inside the StatefulBuilder scope!
                    // Let's just fetch from Firestore again to be completely safe and avoid refactoring.
                    final userDoc = await FirebaseFirestore.instance.collection('users').doc(selectedName).get();
                    if (!userDoc.exists) return;
                    final udata = userDoc.data()!;
                    final title = Helpers.resolveTitle(udata['ecclesiasticalTitle'] ?? '', udata['gender'] ?? 'Masculino');
                    final dName = '$title ${udata['name'] ?? ''}';
                    final pUrl = udata['photoUrl'] ?? '';
                    
                    final List assignments = currentData['assignments'] ?? [];
                    assignments.add({
                      'role': selectedRole,
                      'name': dName,
                      'photoUrl': pUrl,
                    });"""

content = content.replace(old_save, new_save)

with open('lib/screens/admin_escala_screen.dart', 'w') as f:
    f.write(content)
