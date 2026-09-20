import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // for AppColors

class OracaoScreen extends StatefulWidget {
  const OracaoScreen({super.key});

  @override
  State<OracaoScreen> createState() => _OracaoScreenState();
}

class _OracaoScreenState extends State<OracaoScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Set<String> _prayedIds = {};

  @override
  void initState() {
    super.initState();
    _loadPrayedIds();
  }

  Future<void> _loadPrayedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('prayed_for_')).toList();
    setState(() {
      _prayedIds = keys.map((k) => k.replaceFirst('prayed_for_', '')).toSet();
    });
  }

  void _showNewPrayerDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedTarget = 'Toda a Igreja';
    final targets = ['Toda a Igreja', 'Pastores', 'Diáconos', 'Obreiros'];
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Novo Pedido de Oração',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título do Pedido',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Detalhes da Oração',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTarget,
                    decoration: const InputDecoration(
                      labelText: 'Quem pode ver?',
                      border: OutlineInputBorder(),
                    ),
                    items: targets.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() => selectedTarget = val!);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) return;

                            setModalState(() => isSubmitting = true);
                            try {
                              final user = _auth.currentUser;
                              await _firestore.collection('prayers').add({
                                'title': titleController.text.trim(),
                                'description': descriptionController.text.trim(),
                                'target': selectedTarget,
                                'authorId': user?.uid,
                                'authorName': user?.displayName ?? 'Usuário Anônimo',
                                'prayedCount': 0,
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              debugPrint('Erro ao salvar pedido: $e');
                              setModalState(() => isSubmitting = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.goldBright, strokeWidth: 2))
                        : const Text('Enviar Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _prayFor(String docId, int currentCount) async {
    if (_prayedIds.contains(docId)) return;
    
    // Atualiza localmente imediato
    setState(() {
      _prayedIds.add(docId);
    });
    
    // Salva no SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayed_for_$docId', true);

    try {
      await _firestore.collection('prayers').doc(docId).update({
        'prayedCount': FieldValue.increment(1),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você está orando por este pedido! 🙏'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao orar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Pedidos de Oração', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewPrayerDialog,
        backgroundColor: AppColors.goldBright,
        icon: const Icon(Icons.add, color: AppColors.navy),
        label: const Text('Novo Pedido', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('prayers')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os pedidos.'));
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum pedido de oração.\nSeja o primeiro a pedir!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final desc = data['description'] ?? '';
              final target = data['target'] ?? '';
              final authorName = data['authorName'] ?? '';
              final prayedCount = data['prayedCount'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.navy.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              target,
                              style: const TextStyle(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Por: $authorName',
                        style: const TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          desc,
                          style: const TextStyle(fontSize: 15, color: AppColors.ink),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$prayedCount pessoa(s) orando',
                            style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600),
                          ),
                          _prayedIds.contains(doc.id)
                              ? const Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 18, color: AppColors.goldBright),
                                    SizedBox(width: 6),
                                    Text('Você orou', style: TextStyle(color: AppColors.goldBright, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : TextButton.icon(
                                  onPressed: () => _prayFor(doc.id, prayedCount),
                                  icon: const Icon(Icons.volunteer_activism, size: 18, color: AppColors.navy),
                                  label: const Text('Vou Orar', style: TextStyle(color: AppColors.navy)),
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColors.navy.withValues(alpha: 0.05),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
