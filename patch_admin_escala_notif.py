with open('lib/screens/admin_escala_screen.dart', 'r') as f:
    content = f.read()

import re

old_save = """                    await FirebaseFirestore.instance.collection('escala').doc('current').set({
                      'assignments': assignments,
                    }, SetOptions(merge: true));
                    
                    if (context.mounted) Navigator.pop(context);"""

new_save = """                    await FirebaseFirestore.instance.collection('escala').doc('current').set({
                      'assignments': assignments,
                    }, SetOptions(merge: true));
                    
                    if (currentData.containsKey('cultoDate') && currentData['cultoDate'] != null) {
                      final cDate = (currentData['cultoDate'] as Timestamp).toDate();
                      String dateFormatted = DateFormat("dd/MM/yyyy").format(cDate);
                      
                      final cultoName = currentData['cultoName'] ?? '';
                      String timeStr = "";
                      if (cultoName.contains('•')) {
                        final parts = cultoName.split('•');
                        if (parts[1].contains(',')) {
                          timeStr = parts[1].split(',').last.trim();
                        } else {
                          timeStr = parts[1].trim().split(' ').last;
                        }
                      }
                      
                      final dateStr = timeStr.isNotEmpty ? '$dateFormatted às $timeStr' : dateFormatted;

                      await FirebaseFirestore.instance.collection('users').doc(selectedName).collection('notifications').add({
                        'title': 'Nova Escala de Serviço',
                        'message': 'Você foi escalado(a) para: $selectedRole.\\nData e Horário: $dateStr.',
                        'timestamp': FieldValue.serverTimestamp(),
                        'read': false,
                        'type': 'escala'
                      });
                    }
                    
                    if (context.mounted) Navigator.pop(context);"""

content = content.replace(old_save, new_save)

with open('lib/screens/admin_escala_screen.dart', 'w') as f:
    f.write(content)
