import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Para acessar AppColors

class TransactionInfo {
  final String title;
  final DateTime date;
  final double amount;
  final bool isPayment;
  double runningBalance; // Saldo após esta transação

  TransactionInfo({
    required this.title,
    required this.date,
    required this.amount,
    required this.isPayment,
    this.runningBalance = 0.0,
  });
}

// Mock de dados com datas reais para agrupar por mês
final List<TransactionInfo> _mockTransactions = [
  TransactionInfo(title: 'Pagamento Fatura', date: DateTime.now(), amount: 50.00, isPayment: true),
  TransactionInfo(title: '2x Coxinha, 1x Suco', date: DateTime.now().subtract(const Duration(days: 1)), amount: 16.50, isPayment: false),
  TransactionInfo(title: '1x Pão de Queijo', date: DateTime.now().subtract(const Duration(days: 10)), amount: 8.00, isPayment: false),
  TransactionInfo(title: 'Pagamento Fatura', date: DateTime(DateTime.now().year, DateTime.now().month - 1, 20), amount: 30.00, isPayment: true),
  TransactionInfo(title: '1x Bolo de Cenoura', date: DateTime(DateTime.now().year, DateTime.now().month - 1, 15), amount: 7.00, isPayment: false),
  TransactionInfo(title: '1x Misto Quente', date: DateTime(DateTime.now().year, DateTime.now().month - 2, 5), amount: 12.00, isPayment: false),
];

class ConvenioScreen extends StatefulWidget {
  const ConvenioScreen({super.key});

  @override
  State<ConvenioScreen> createState() => _ConvenioScreenState();
}

class _ConvenioScreenState extends State<ConvenioScreen> {
  final Map<String, List<TransactionInfo>> _groupedTransactions = {};
  
  @override
  void initState() {
    super.initState();
    _processAndGroupTransactions();
  }

  void _processAndGroupTransactions() {
    // 1. Ordena do mais antigo para o mais novo para calcular o saldo progressivo
    _mockTransactions.sort((a, b) => a.date.compareTo(b.date));

    double currentBalance = 0.0;
    for (var t in _mockTransactions) {
      if (t.isPayment) {
        currentBalance += t.amount;
      } else {
        currentBalance -= t.amount;
      }
      t.runningBalance = currentBalance;
    }

    // 2. Ordena de volta: do mais recente para o mais antigo (para exibição)
    _mockTransactions.sort((a, b) => b.date.compareTo(a.date));

    // 3. Agrupa por mês
    for (var t in _mockTransactions) {
      final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(t.date);
      final formattedMonth = "${monthName[0].toUpperCase()}${monthName.substring(1)}";
      
      if (!_groupedTransactions.containsKey(formattedMonth)) {
        _groupedTransactions[formattedMonth] = [];
      }
      _groupedTransactions[formattedMonth]!.add(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPayments = _mockTransactions.where((t) => t.isPayment).fold(0, (sum, t) => sum + t.amount);
    double totalConsumption = _mockTransactions.where((t) => !t.isPayment).fold(0, (sum, t) => sum + t.amount);
    double balance = totalPayments - totalConsumption;

    final months = _groupedTransactions.keys.toList();
    final hasMultipleMonths = months.length > 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Convênio Cantina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header de Saldo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.navyDeep,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Saldo Disponível',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${balance.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppColors.goldBright,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SummaryCard(
                      title: 'Consumido',
                      amount: totalConsumption,
                      color: Colors.red[300]!,
                    ),
                    _SummaryCard(
                      title: 'Pago',
                      amount: totalPayments,
                      color: Colors.green[400]!,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Extrato de Consumo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDeep,
                ),
              ),
            ),
          ),
          
          // Lista Agrupada por Mês
          Expanded(
            child: _groupedTransactions.isEmpty
                ? const Center(child: Text('Nenhum consumo registrado.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final transactions = _groupedTransactions[month]!;
                      final isCurrentMonth = index == 0;

                      if (!hasMultipleMonths) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Text(month, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.muted)),
                            ),
                            ...transactions.map((t) => _buildTransactionCard(t)),
                          ],
                        );
                      }

                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: isCurrentMonth,
                          title: Text(
                            month,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCurrentMonth ? AppColors.navyDeep : AppColors.muted,
                            ),
                          ),
                          children: transactions.map((t) => _buildTransactionCard(t)).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionInfo transaction) {
    final isPayment = transaction.isPayment;
    final dateStr = DateFormat('dd/MM, HH:mm').format(transaction.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isPayment ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          child: Icon(
            isPayment ? Icons.account_balance_wallet : Icons.fastfood,
            color: isPayment ? Colors.green : Colors.redAccent,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink, fontSize: 15),
        ),
        subtitle: Text(
          dateStr,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Saldo: R\$ ${transaction.runningBalance.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${isPayment ? '+' : '-'} R\$ ${transaction.amount.toStringAsFixed(2).replaceAll('.', ',')}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isPayment ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
