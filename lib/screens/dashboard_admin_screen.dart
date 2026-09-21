import 'package:flutter/material.dart';

import '../main.dart' show AppColors;
import 'admin_screen.dart'; // The one we built with member list
import 'convenio_screen.dart';
import 'admin_cultos_screen.dart'; // The cantina screen

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  Widget _buildDashboardCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.navyDeep, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Administração Central',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecione o módulo que deseja gerenciar.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildDashboardCard(
            context,
            title: 'Membros e Acessos',
            subtitle: 'Gerencie cargos, patentes e níveis de sistema',
            icon: Icons.people_alt_outlined,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            title: 'Cultos / Programação',
            subtitle: 'Gerencie os cultos e eventos na tela inicial',
            icon: Icons.calendar_month_outlined,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCultosScreen()));
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            title: 'Cantina / Conveniência',
            subtitle: 'Gerencie o cardápio e os pedidos da cantina',
            icon: Icons.storefront_outlined,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ConvenioScreen()));
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            title: 'Tesouraria',
            subtitle: 'Relatórios de dízimos e ofertas',
            icon: Icons.account_balance_wallet_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Módulo de Tesouraria em breve!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
