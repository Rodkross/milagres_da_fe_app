import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart'; // Para acessar AppColors

class OfertasScreen extends StatelessWidget {
  const OfertasScreen({super.key});

  void _copiarTexto(BuildContext context, String texto, String label) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado com sucesso!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Ofertas e Dízimos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Bíblico
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x2A000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
                image: DecorationImage(
                  image: const NetworkImage('https://images.unsplash.com/photo-1495640388908-05fa85288e61?q=80&w=600&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.60), // Película escura para dar destaque total à imagem e ao texto claro
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.format_quote_rounded, size: 40, color: AppColors.goldBright),
                  const SizedBox(height: 12),
                  const Text(
                    "Cada um dê conforme determinou em seu coração, não com pesar ou por obrigação, pois Deus ama quem dá com alegria.",
                    style: TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.5,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "2 Coríntios 9:7",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldBright,
                      shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Dados para Transferência',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDeep,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Card PIX
            _InfoCard(
              icon: Icons.pix,
              title: 'Chave PIX (E-mail)',
              value: 'milagresdafe2018@gmail.com',
              onCopy: () => _copiarTexto(context, 'milagresdafe2018@gmail.com', 'Chave PIX'),
            ),
            
            const SizedBox(height: 16),
            
            // Card Conta
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, color: AppColors.navy),
                      const SizedBox(width: 12),
                      const Text(
                        'Conta Bancária',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, color: AppColors.gold),
                        onPressed: () {
                          const dados = 'Banco: PicPay\nAgência: 1\nConta: 121547597-7';
                          _copiarTexto(context, dados, 'Dados da conta');
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Banco', 'PicPay'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Agência', '1'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Conta', '121547597-7'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 15)),
        Text(value, style: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.navy),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.gold),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}
