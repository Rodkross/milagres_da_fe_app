import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart' show AppColors;
import 'member_details_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Painel de Liderança'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          final users = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Desconhecido';
              final email = data['email'] ?? '';
              final dept = data['departmentAccess'] ?? 'membresia';
              final title = data['ecclesiasticalTitle'] ?? 'Membro';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.muted,
                  foregroundColor: Colors.white,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                subtitle: Text('$title • Acesso: ${dept.toUpperCase()} \n$email'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right, color: AppColors.gold),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MemberDetailsScreen(userDoc: doc)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
