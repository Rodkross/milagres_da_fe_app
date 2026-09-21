import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // Para acessar AppColors

class CultosScreen extends StatelessWidget {
  const CultosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.navyDark,
        title: const Text(
          'Nossos Cultos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.goldBright),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cultos').orderBy('order').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.goldBright));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar cultos: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum culto cadastrado ainda.', style: TextStyle(color: AppColors.muted)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _CultoCard(
                title: data['title'] ?? '',
                day: data['day'] ?? '',
                time: data['time'] ?? '',
                location: data['location'] ?? '',
                imageUrl: data['imageUrl'],
              );
            },
          );
        },
      ),
    );
  }
}

class _CultoCard extends StatelessWidget {
  const _CultoCard({
    required this.title,
    required this.day,
    required this.time,
    required this.location,
    this.imageUrl,
  });

  final String title;
  final String day;
  final String time;
  final String location;
  final String? imageUrl; // Placeholder para futura URL da imagem

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0B2E5B),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área de conteúdo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Área da imagem (direita)
            Container(
              width: 110,
              decoration: BoxDecoration(
                color: AppColors.surface, // Cor de fundo
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.muted,
                        size: 32,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
