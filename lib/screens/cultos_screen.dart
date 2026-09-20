import 'package:flutter/material.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _CultoCard(
            title: 'Culto de Libertação',
            day: 'Toda Quinta',
            time: '19:00',
            location: 'Igreja',
          ),
          SizedBox(height: 16),
          _CultoCard(
            title: 'Culto da Família e Adoração',
            day: 'Todo Domingo',
            time: '18:00',
            location: 'Igreja',
          ),
          SizedBox(height: 16),
          _CultoCard(
            title: 'Culto de Consagração',
            day: 'Último Sábado do mês',
            time: '09:00',
            location: 'Igreja',
          ),
          SizedBox(height: 16),
          _CultoCard(
            title: 'Santa Ceia',
            day: 'Todo Segundo Domingo',
            time: '09:00',
            location: 'Igreja',
          ),
          SizedBox(height: 16),
          _CultoCard(
            title: 'Célula',
            day: 'Toda Segunda',
            time: '19:30',
            location: 'Casa dos Pastores',
          ),
        ],
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
            // Área reservada para a imagem
            Container(
              width: 110,
              decoration: const BoxDecoration(
                color: AppColors.surface, // Cor de fundo do placeholder
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.muted,
                  size: 32,
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
