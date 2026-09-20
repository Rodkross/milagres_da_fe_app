import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../main.dart'; // for AppColors

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> _allQuestions = [];
  List<dynamic> _sessionQuestions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/quiz_biblico.json');
      final data = json.decode(jsonString) as List<dynamic>;
      data.shuffle();
      setState(() {
        _allQuestions = data;
        // Selecionar 10 perguntas para a rodada
        _sessionQuestions = data.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar o quiz: $e');
      setState(() => _isLoading = false);
    }
  }

  void _answerQuestion(String option, String correctAnswer) {
    if (_hasAnswered) return;
    setState(() {
      _selectedOption = option;
      _hasAnswered = true;
      if (option == correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentIndex < _sessionQuestions.length - 1) {
        _currentIndex++;
        _hasAnswered = false;
        _selectedOption = null;
      } else {
        // Fim do quiz
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Fim de Jogo!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Você acertou $_score de ${_sessionQuestions.length}!',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Continue estudando a Palavra para se aprimorar cada vez mais.',
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fechar dialog
                Navigator.pop(context); // Voltar pra home
              },
              child: const Text('Voltar ao Início'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
              onPressed: () {
                Navigator.pop(context);
                // Reiniciar
                _allQuestions.shuffle();
                setState(() {
                  _sessionQuestions = _allQuestions.take(10).toList();
                  _currentIndex = 0;
                  _score = 0;
                  _hasAnswered = false;
                  _selectedOption = null;
                });
              },
              child: const Text('Jogar Novamente', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(backgroundColor: AppColors.navyDeep),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_sessionQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(backgroundColor: AppColors.navyDeep),
        body: const Center(child: Text('Erro ao carregar perguntas.')),
      );
    }

    final currentQuestion = _sessionQuestions[_currentIndex];
    final questionText = currentQuestion['pergunta'] as String;
    final options = List<String>.from(currentQuestion['opcoes']);
    final correctAnswer = currentQuestion['resposta_correta'] as String;
    final reference = currentQuestion['referencia'] as String?;
    final hint = currentQuestion['dica'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Quiz Bíblico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra de progresso e Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pergunta ${_currentIndex + 1} / ${_sessionQuestions.length}',
                      style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                  Text('Pontos: $_score',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _sessionQuestions.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 32),
              
              // Pergunta
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Text(
                  questionText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              
              // Opções
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = _selectedOption == option;
                    final isCorrect = option == correctAnswer;
                    
                    Color bgColor = Colors.white;
                    Color borderColor = AppColors.divider;
                    Color textColor = AppColors.ink;

                    if (_hasAnswered) {
                      if (isCorrect) {
                        bgColor = Colors.green[100]!;
                        borderColor = Colors.green;
                        textColor = Colors.green[800]!;
                      } else if (isSelected) {
                        bgColor = Colors.red[100]!;
                        borderColor = Colors.red;
                        textColor = Colors.red[800]!;
                      }
                    }

                    return GestureDetector(
                      onTap: () => _answerQuestion(option, correctAnswer),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (_hasAnswered && isCorrect)
                              const Icon(Icons.check_circle, color: Colors.green),
                            if (_hasAnswered && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Feedback e Referência
              if (_hasAnswered) ...[
                if (reference != null || hint != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.navy.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reference != null)
                          Text('📖 Referência: $reference',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
                        if (hint != null) ...[
                          const SizedBox(height: 4),
                          Text('💡 $hint', style: const TextStyle(color: AppColors.ink)),
                        ]
                      ],
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _nextQuestion,
                  child: const Text('Próxima', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
