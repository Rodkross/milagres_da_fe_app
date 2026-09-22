import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // Para AppColors e formatação de datas
import 'package:intl/intl.dart';
import '../helpers.dart';

class AdminEscalaScreen extends StatefulWidget {
  const AdminEscalaScreen({super.key});

  @override
  State<AdminEscalaScreen> createState() => _AdminEscalaScreenState();
}

class _AdminEscalaScreenState extends State<AdminEscalaScreen> {
  bool _isLoading = false;

  Future<List<Map<String, String>>> _fetchObreiros() async {
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
  }

  void _showAddRoleDialog(BuildContext context, Map<String, dynamic> currentData) {
    String? selectedRole;
    String? selectedName;
    
    // Cache the future so it doesn't re-fetch on every dropdown selection (setState)
    final _obreirosFuture = _fetchObreiros();
    
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
    
    final roles = allRoles.where((r) => !alreadyAssigned.contains(r)).toList();
    
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
                    roles.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Todas as funções já foram preenchidas!', style: TextStyle(color: Colors.red)),
                          )
                        : DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Função'),
                            value: selectedRole,
                            items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                            onChanged: (val) => setState(() => selectedRole = val),
                          ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, String>>>(
                      future: _obreirosFuture,
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
                        if (selectedName != null && !users.any((u) => u['id'] == selectedName)) {
                          selectedName = null;
                        }

                        return DropdownButtonFormField<String>(
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
  }

  DateTime? _parseNextOccurrence(String dayStr, String timeStr) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escala de Serviço'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('escala').doc('current').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final isDefined = data.containsKey('cultoDate') && data['cultoDate'] != null;
          
          DateTime? cultoDate;
          bool isExpired = false;
          
          if (isDefined) {
            cultoDate = (data['cultoDate'] as Timestamp).toDate();
            // Expira no dia seguinte ao culto, a partir da meia-noite.
            final expirationDate = DateTime(cultoDate.year, cultoDate.month, cultoDate.day).add(const Duration(days: 1));
            final now = DateTime.now();
            if (now.isAfter(expirationDate)) {
              isExpired = true;
            }
          }

          if (isExpired || !isDefined) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    isExpired ? 'A escala anterior expirou.' : 'Nenhuma escala definida.',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldBright,
                      foregroundColor: AppColors.navyDeep,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      // Limpar escala antiga antes de criar
                      if (isExpired) {
                        await FirebaseFirestore.instance.collection('escala').doc('current').set({});
                      }
                      if (context.mounted) {
                         _selectDateAndCulto(context, {});
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Iniciar Nova Escala'),
                  )
                ],
              ),
            );
          }

          final cultoName = data['cultoName'] ?? '';
          final assignments = List<Map<String, dynamic>>.from(data['assignments'] ?? []);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                color: AppColors.navy.withValues(alpha: 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Escala Ativa:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '$cultoName • ${DateFormat('dd/MM/yyyy').format(cultoDate!)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _selectDateAndCulto(context, data),
                          icon: const Icon(Icons.edit_calendar, size: 16),
                          label: const Text('Editar Culto'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            FirebaseFirestore.instance.collection('escala').doc('current').delete();
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Apagar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: assignments.isEmpty 
                  ? const Center(child: Text('Nenhum serviço adicionado ainda.'))
                  : ListView.builder(
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final item = assignments[index];
                        final pUrl = item['photoUrl'] as String?;
                        return ListTile(
                          leading: pUrl != null && pUrl.isNotEmpty
                              ? CircleAvatar(backgroundImage: NetworkImage(pUrl))
                              : const CircleAvatar(
                                  backgroundColor: AppColors.goldBright,
                                  child: Icon(Icons.person_outline, color: AppColors.navyDeep),
                                ),
                          title: Text(item['role'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item['name'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              assignments.removeAt(index);
                              FirebaseFirestore.instance.collection('escala').doc('current').set({
                                'assignments': assignments
                              }, SetOptions(merge: true));
                            },
                          ),
                        );
                      },
                    ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddRoleDialog(context, data),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldBright, foregroundColor: AppColors.navyDeep),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Serviço'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
