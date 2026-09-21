import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart' show AppColors;

class MemberDetailsScreen extends StatelessWidget {
  const MemberDetailsScreen({super.key, required this.userDoc});

  final DocumentSnapshot userDoc;

  void _showEditRoleDialog(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final data = userDoc.data() as Map<String, dynamic>;
    String currentDept = data['departmentAccess'] ?? 'membresia';
    String currentTitle = data['ecclesiasticalTitle'] ?? 'Membro';
    final name = data['name'] ?? 'Usuário';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Gerenciar $name',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: currentDept,
                    decoration: const InputDecoration(
                      labelText: 'Acesso ao Sistema (Departamento)',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'membresia', child: Text('Membresia (Padrão)')),
                      DropdownMenuItem(value: 'cantina', child: Text('Cantina')),
                      DropdownMenuItem(value: 'tesouraria', child: Text('Tesouraria')),
                      DropdownMenuItem(value: 'secretaria', child: Text('Secretaria')),
                      DropdownMenuItem(value: 'presidencia', child: Text('Presidência (Acesso Total)')),
                    ],
                    onChanged: (val) => setModalState(() => currentDept = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: currentTitle,
                    decoration: const InputDecoration(
                      labelText: 'Patente / Cargo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Visitante', child: Text('Visitante')),
                      DropdownMenuItem(value: 'Membro', child: Text('Membro')),
                      DropdownMenuItem(value: 'Obreiro(a)', child: Text('Obreiro(a)')),
                      DropdownMenuItem(value: 'Diácono / Diaconisa', child: Text('Diácono / Diaconisa')),
                      DropdownMenuItem(value: 'Presbítero(a)', child: Text('Presbítero(a)')),
                      DropdownMenuItem(value: 'Pastor(a)', child: Text('Pastor(a)')),
                    ],
                    onChanged: (val) => setModalState(() => currentTitle = val!),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await _firestore.collection('users').doc(userDoc.id).update({
                          'departmentAccess': currentDept,
                          'ecclesiasticalTitle': currentTitle,
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Acesso atualizado com sucesso!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro de Permissão (Firebase Rules)'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.navyDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salvar Alterações', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, color: AppColors.navy)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userDoc.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Desconhecido';
        final email = data['email'] ?? 'Sem e-mail';
        final phone = data['phone'] ?? '';
        
        String formatDate(dynamic date) {
          if (date is Timestamp) {
            final DateTime d = date.toDate();
            return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
          }
          return date?.toString() ?? '';
        }

        final birthDate = formatDate(data['birthDate']);
        final baptismDate = formatDate(data['baptismDate']);
        final conversionDate = formatDate(data['conversionDate']);
        final about = data['aboutMe'] ?? '';
        final dept = data['departmentAccess'] ?? 'membresia';
        final title = data['ecclesiasticalTitle'] ?? 'Membro';

        String addressString = '';
        if (data['address'] is Map) {
          final addressMap = data['address'] as Map<String, dynamic>;
          addressString = [
            addressMap['street'],
            addressMap['number'],
            addressMap['complement'],
            addressMap['neighborhood'],
            addressMap['city'],
            addressMap['state']
          ].where((p) => p != null && p.toString().trim().isNotEmpty).join(', ');
        } else if (data['address'] is String) {
          addressString = data['address'] as String;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ficha de Membro'),
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: AppColors.goldBright),
                tooltip: 'Alterar Cargo e Permissões',
                onPressed: () => _showEditRoleDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.muted,
                    foregroundColor: Colors.white,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    '$title • Acesso: ${dept.toUpperCase()}',
                    style: const TextStyle(fontSize: 14, color: AppColors.gold, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Informações de Contato', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const Divider(),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.email_outlined, 'E-mail', email.isNotEmpty ? email : 'Não informado'),
                _buildInfoRow(Icons.phone_outlined, 'Celular', phone.isNotEmpty ? phone : 'Não informado'),
                _buildInfoRow(Icons.location_on_outlined, 'Endereço', addressString.isNotEmpty ? addressString : 'Não informado'),
                
                const SizedBox(height: 24),
                const Text('Datas Importantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const Divider(),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.cake_outlined, 'Data de Nascimento', birthDate.isNotEmpty ? birthDate : 'Não informado'),
                _buildInfoRow(Icons.favorite_border, 'Conversão', conversionDate.isNotEmpty ? conversionDate : 'Não informado'),
                _buildInfoRow(Icons.water_drop_outlined, 'Batismo nas Águas', baptismDate.isNotEmpty ? baptismDate : 'Não informado'),

                const SizedBox(height: 24),
                const Text('Sobre / Biografia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  about.isNotEmpty ? about : 'Nenhuma biografia registrada.',
                  style: TextStyle(fontSize: 15, color: about.isNotEmpty ? Colors.black87 : Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldBright,
                      foregroundColor: AppColors.navyDeep,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: () => _showEditRoleDialog(context),
                    icon: const Icon(Icons.admin_panel_settings, size: 24),
                    label: const Text(
                      'Alterar Permissões e Cargo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (email.isNotEmpty && email != 'Sem e-mail')
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.navy, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('E-mail de redefinição enviado para $email'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao enviar e-mail: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.lock_reset_outlined, size: 24),
                      label: const Text(
                        'Enviar Redefinição de Senha',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
