with open('lib/screens/admin_escala_screen.dart', 'r') as f:
    content = f.read()

import re

old_select_date = """  Future<void> _selectDateAndCulto(BuildContext context, Map<String, dynamic>? currentData) async {
    DateTime initial = DateTime.now();
    if (currentData != null && currentData['cultoDate'] != null) {
      initial = (currentData['cultoDate'] as Timestamp).toDate();
    }
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (pickedDate == null || !context.mounted) return;
    
    final nameCtrl = TextEditingController(text: currentData?['cultoName'] ?? '');
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Definir Culto da Escala'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Nome do Culto (ex: Culto de Libertação)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                
                await FirebaseFirestore.instance.collection('escala').doc('current').set({
                  'cultoDate': Timestamp.fromDate(pickedDate),
                  'cultoName': nameCtrl.text.trim(),
                  'assignments': currentData?['assignments'] ?? [],
                }, SetOptions(merge: true));
                
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      }
    );
  }"""

new_select_date = """  DateTime? _parseNextOccurrence(String dayStr, String timeStr) {
    final str = dayStr.toLowerCase();
    int? targetWeekday;
    if (str.contains('segunda')) targetWeekday = 1;
    else if (str.contains('terça') || str.contains('terca')) targetWeekday = 2;
    else if (str.contains('quarta')) targetWeekday = 3;
    else if (str.contains('quinta')) targetWeekday = 4;
    else if (str.contains('sexta')) targetWeekday = 5;
    else if (str.contains('sábado') || str.contains('sabado')) targetWeekday = 6;
    else if (str.contains('domingo')) targetWeekday = 7;

    if (targetWeekday == null) return null;

    final now = DateTime.now();
    int daysAhead = targetWeekday - now.weekday;
    
    if (daysAhead < 0) {
      daysAhead += 7;
    } else if (daysAhead == 0) {
      // É hoje. Verificar se já passou do horário.
      int hour = 23;
      int minute = 59;
      if (timeStr.isNotEmpty) {
        final parts = timeStr.split(':');
        if (parts.isNotEmpty) hour = int.tryParse(parts[0]) ?? 23;
        if (parts.length > 1) minute = int.tryParse(parts[1]) ?? 59;
      }
      final timeOfCulto = DateTime(now.year, now.month, now.day, hour, minute);
      if (now.isAfter(timeOfCulto)) {
        daysAhead += 7; // Já passou hoje, joga pra semana que vem
      }
    }

    return DateTime(now.year, now.month, now.day).add(Duration(days: daysAhead));
  }

  Future<void> _selectDateAndCulto(BuildContext context, Map<String, dynamic>? currentData) async {
    // 1. Tentar descobrir qual é o próximo culto automaticamente
    String suggestedName = currentData?['cultoName'] ?? '';
    DateTime suggestedDate = DateTime.now();
    if (currentData != null && currentData['cultoDate'] != null) {
      suggestedDate = (currentData['cultoDate'] as Timestamp).toDate();
    } else {
      // Não tem escala, vamos buscar nos cultos
      try {
        final cultosSnap = await FirebaseFirestore.instance.collection('cultos').get();
        DateTime? closestDate;
        String? closestName;
        
        for (var doc in cultosSnap.docs) {
          final data = doc.data();
          final title = data['title'] as String? ?? '';
          final day = data['day'] as String? ?? '';
          final time = data['time'] as String? ?? '';
          
          final nextDate = _parseNextOccurrence(day, time);
          if (nextDate != null) {
            if (closestDate == null || nextDate.isBefore(closestDate)) {
              closestDate = nextDate;
              closestName = '$title • $day, $time';
            }
          }
        }
        
        if (closestDate != null && closestName != null) {
          suggestedDate = closestDate;
          suggestedName = closestName;
        }
      } catch (e) {
        debugPrint('Erro ao calcular proximo culto: $e');
      }
    }

    if (!context.mounted) return;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: suggestedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (pickedDate == null || !context.mounted) return;
    
    final nameCtrl = TextEditingController(text: suggestedName);
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Definir Culto da Escala'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Nome do Culto (ex: Culto de Libertação)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                
                await FirebaseFirestore.instance.collection('escala').doc('current').set({
                  'cultoDate': Timestamp.fromDate(pickedDate),
                  'cultoName': nameCtrl.text.trim(),
                  'assignments': currentData?['assignments'] ?? [],
                }, SetOptions(merge: true));
                
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      }
    );
  }"""

content = content.replace(old_select_date, new_select_date)

with open('lib/screens/admin_escala_screen.dart', 'w') as f:
    f.write(content)
