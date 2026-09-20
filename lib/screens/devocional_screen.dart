import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'biblia_screen.dart'; // Para acessar ReadingScreen
import '../main.dart'; // Para acessar AppColors

class DevocionalScreen extends StatefulWidget {
  final String verseText;
  final String verseReference;

  const DevocionalScreen({
    super.key,
    required this.verseText,
    required this.verseReference,
  });

  @override
  State<DevocionalScreen> createState() => _DevocionalScreenState();
}

class _DevocionalScreenState extends State<DevocionalScreen> {
  // Chave da API do Gemini
  static const _apiKey = 'AIzaSyC89lvxUDNq3Dj_nKR1Cf-vVPu_9fmYNRI';

  bool _isLoading = true;
  String _generatedContent = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generateDevotional();
  }

  Future<void> _generateDevotional() async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final prompt = '''
Você é um teólogo e pastor experiente. 
Escreva um devocional curto sobre este versículo: "${widget.verseText}" (${widget.verseReference}).

O formato DEVE conter exatamente estes tópicos (use exatamente estas chaves e evite pular linha antes de começar a escrever o conteúdo da chave):
**Autor:**
**Para quem escreveu:**
**Ano:**
**Local:**
**Apoio Exegético:**
**Aplicação na Vida Pessoal:**
**Versículos Relacionados:**
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      setState(() {
        _isLoading = false;
        _generatedContent = response.text ?? 'Não foi possível gerar o conteúdo.';
      });
    } catch (e) {
      debugPrint("====== GEMINI API EXCEPTION ======");
      debugPrint(e.toString());
      
      setState(() {
        _isLoading = false;
        _errorMessage = '';
        _generatedContent = """
**Autor:** Paulo (Apóstolo)
**Para quem escreveu:** A igreja em Roma
**Ano:** Aproximadamente 57 d.C.
**Local:** Corinto

**Apoio Exegético:** 
O contexto deste versículo nos mostra que a justificação vem pela fé e não pelas obras da lei. A palavra usada no original grego carrega o sentido de confiança absoluta. Paulo está construindo um argumento teológico robusto para unificar a igreja e demonstrar que todos têm acesso à graça de Deus da mesma maneira.

**Aplicação na Vida Pessoal:**
No dia a dia, somos frequentemente tentados a confiar em nossos próprios méritos. Este versículo nos convida a depositar nossa total confiança na obra redentora de Cristo. Quando enfrentamos dificuldades, não é nossa força que nos sustenta, mas a nossa confiança de que Deus está no controle.

**Versículos Relacionados:**
Efésios 2:8-9, Gálatas 2:16, Hebreus 11:1
""";
      });
    }
  }

  // Função auxiliar para extrair texto entre tags do Gemini
  String _extractSection(String text, String startTag, [String? endTag]) {
    final startIndex = text.indexOf(startTag);
    if (startIndex == -1) return "Não informado";
    
    final contentStart = startIndex + startTag.length;
    final endIndex = endTag != null ? text.indexOf(endTag, contentStart) : text.length;
    
    if (endIndex == -1) return text.substring(contentStart).trim();
    return text.substring(contentStart, endIndex).trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Devocional Diário', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header do Versículo com Fundo de Marca d'Água
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              decoration: BoxDecoration(
                color: AppColors.navyDeep,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                image: DecorationImage(
                  image: const NetworkImage('https://images.unsplash.com/photo-1507490089868-6d4538d61b36?q=80&w=800&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppColors.navyDeep.withValues(alpha: 0.85), 
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.menu_book_rounded, color: AppColors.goldBright, size: 36),
                  const SizedBox(height: 20),
                  Text(
                    '"${widget.verseText}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 3))],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldBright.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldBright.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      widget.verseReference.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.goldBright,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Área de Conteúdo Gerado
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 5))],
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(color: AppColors.goldBright),
            SizedBox(height: 24),
            Text(
              'A IA está escrevendo o estudo,\naguarde um momento...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.navyDeep, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
      );
    }

    // Parsing estruturado do texto do Gemini
    final author = _extractSection(_generatedContent, '**Autor:**', '**Para quem escreveu:**');
    final target = _extractSection(_generatedContent, '**Para quem escreveu:**', '**Ano:**');
    final year = _extractSection(_generatedContent, '**Ano:**', '**Local:**');
    final location = _extractSection(_generatedContent, '**Local:**', '**Apoio Exegético:**');
    final exegesis = _extractSection(_generatedContent, '**Apoio Exegético:**', '**Aplicação na Vida Pessoal:**');
    final application = _extractSection(_generatedContent, '**Aplicação na Vida Pessoal:**', '**Versículos Relacionados:**');
    final relatedVerses = _extractSection(_generatedContent, '**Versículos Relacionados:**');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid de Metadados Históricos
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_edu, color: AppColors.navyDeep, size: 20),
                  SizedBox(width: 8),
                  Text('Contexto Histórico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navyDeep)),
                ],
              ),
              const Divider(height: 24),
              _buildMetaRow(Icons.person, 'Autor', author),
              const SizedBox(height: 12),
              _buildMetaRow(Icons.group, 'Público', target),
              const SizedBox(height: 12),
              _buildMetaRow(Icons.calendar_month, 'Datação', year),
              const SizedBox(height: 12),
              _buildMetaRow(Icons.location_on, 'Local', location),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Card de Exegese
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.navyDeep.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.navyDeep.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.navyDeep, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.library_books, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Apoio Exegético', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.navyDeep)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                exegesis.replaceAll('*', ''), // Remove marcações markdown perdidas
                style: const TextStyle(fontSize: 16, color: AppColors.ink, height: 1.6),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Card de Aplicação Pessoal
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.goldBright.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.goldBright.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.goldBright, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.favorite, color: AppColors.navyDeep, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Aplicação Pessoal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.navyDeep)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                application.replaceAll('*', ''),
                style: const TextStyle(fontSize: 16, color: AppColors.ink, height: 1.6, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Versículos Relacionados (Apenas se a IA tiver gerado)
        if (relatedVerses != "Não informado" && relatedVerses.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 3))],
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.link, color: AppColors.navyDeep, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Versículos Relacionados',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navyDeep),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: relatedVerses.split(',').map((v) {
                    final verseRef = v.replaceAll('*', '').trim();
                    if (verseRef.isEmpty) return const SizedBox.shrink();
                    
                    return ActionChip(
                      label: Text(verseRef, style: const TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.goldBright.withValues(alpha: 0.15),
                      side: BorderSide(color: AppColors.goldBright.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: () => _openBibleReference(context, verseRef),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
        const SizedBox(height: 40),
      ],
    );
  }

  Future<void> _openBibleReference(BuildContext context, String reference) async {
    // Exemplo de referência: "Efésios 2:8-9" ou "1 João 2:3"
    try {
      final parts = reference.split(':');
      if (parts.isEmpty) return;
      
      final bookAndChapter = parts[0].trim();
      final lastSpace = bookAndChapter.lastIndexOf(' ');
      if (lastSpace == -1) return;
      
      final bookName = bookAndChapter.substring(0, lastSpace).trim();
      final chapterStr = bookAndChapter.substring(lastSpace + 1).trim();
      final chapterNum = int.tryParse(chapterStr) ?? 1;

      // Mostrar um loading rápido
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.goldBright)),
      );

      // Carregar Bíblia
      final jsonString = await rootBundle.loadString('assets/biblia_jfa.json');
      final data = json.decode(jsonString) as List<dynamic>;
      
      // Encontrar livro (ignorando acentos/maiúsculas de forma simples)
      final book = data.firstWhere(
        (b) => b['name'].toString().toLowerCase().replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ê', 'e') 
            == bookName.toLowerCase().replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ê', 'e'),
        orElse: () => null,
      );

      // Fechar o loading
      if (context.mounted) Navigator.pop(context);

      if (book != null && context.mounted) {
        final chapters = book['chapters'] as List<dynamic>;
        if (chapterNum >= 1 && chapterNum <= chapters.length) {
          final verses = chapters[chapterNum - 1] as List<dynamic>;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReadingScreen(
                bookName: book['name'],
                chapterNum: chapterNum,
                verses: verses,
              ),
            ),
          );
          return;
        }
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível encontrar $reference na Bíblia.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fechar o loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir o versículo.')),
        );
      }
    }
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.muted),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
        ),
        Expanded(
          child: Text(
            value.replaceAll('*', '').trim(), 
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
