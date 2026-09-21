import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'biblia_screen.dart'; // Para acessar ReadingScreen
import '../main.dart'; // Para acessar AppColors

class DevocionalScreen extends StatefulWidget {
  final String verseText;
  final String verseReference;
  final bool isStudy;

  const DevocionalScreen({
    super.key,
    required this.verseText,
    required this.verseReference,
    this.isStudy = false,
  });

  @override
  State<DevocionalScreen> createState() => _DevocionalScreenState();
}

class _DevocionalScreenState extends State<DevocionalScreen> {
  // Chave atualizada
  // A chave de API agora é lida via variável de ambiente no momento do build
  final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

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
      // 1. Tentar ler do Cache Global (Firestore)
      final docId = widget.verseReference.replaceAll('/', '-').replaceAll(':', '_').replaceAll(' ', '').toLowerCase();
      final cacheRef = FirebaseFirestore.instance.collection('cached_devotionals').doc(docId);
      final cacheSnapshot = await cacheRef.get();

      if (cacheSnapshot.exists) {
        // Encontrou no cache! Carregamento imediato sem custo de IA.
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _generatedContent = cacheSnapshot.data()?['content'] ?? 'Erro ao ler cache.';
        });
        return;
      }

      // 2. Se não existir no cache, chamar a Inteligência Artificial
      String generatedText = '';
      final modelsToTry = ['gemini-3.6-flash', 'gemini-3.5-flash', 'gemini-flash-latest'];
      
      for (int i = 0; i < modelsToTry.length; i++) {
        try {
          final model = GenerativeModel(model: modelsToTry[i], apiKey: _apiKey);
          final prompt = '''
Você é um teólogo e pastor experiente. 
Escreva um devocional curto sobre este versículo: "${widget.verseText}" (${widget.verseReference}).

O formato DEVE conter exatamente estes tópicos (use exatamente estas chaves e evite pular linha antes de começar a escrever o conteúdo da chave):

Responda o contexto histórico do livro bíblico:
**Autor:** (Quem escreveu este livro da Bíblia)
**Para quem escreveu:** (Público original)
**Ano:** (Ano ou período aproximado em que o livro foi escrito)
**Local:** (De onde foi escrito ou onde ocorreu)

Responda o estudo e devocional:
**Apoio Exegético:**
**Aplicação na Vida Pessoal:**
**Versículos Relacionados:** (Liste 2 ou 3 versículos relacionados SEPARADOS EXATAMENTE POR VÍRGULA. Exemplo: João 3:16, Salmos 23:1, Romanos 8:28)
''';
          final content = [Content.text(prompt)];
          final response = await model.generateContent(content);
          generatedText = response.text ?? '';
          
          if (generatedText.isNotEmpty) {
            break; // Se deu certo, sai do loop
          }
        } catch (e) {
          debugPrint('Falha ao usar modelo ${modelsToTry[i]}: $e');
          if (i == modelsToTry.length - 1) {
            rethrow; // Se foi o último modelo e falhou, joga o erro para fora
          }
          // Aguarda um pequeno delay (Exponential Backoff) antes de tentar o próximo modelo (2s, depois 4s...)
          await Future.delayed(Duration(seconds: 2 * (i + 1)));
        }
      }
      
      if (generatedText.isEmpty) {
        throw Exception('Todos os modelos falharam ao gerar conteúdo.');
      }

      // 3. Salvar a nova resposta no Banco de Dados para que a Igreja toda acesse instantaneamente
      try {
        await cacheRef.set({
          'verseReference': widget.verseReference,
          'content': generatedText,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Erro ao salvar no cache: $e'); // Ignora e apenas mostra no app se falhar o cache
      }
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _generatedContent = generatedText;
      });
    } catch (e) {
      debugPrint("====== GEMINI API EXCEPTION ======");
      debugPrint(e.toString());
      
      String errorMessage = "Não foi possível gerar a exegese neste momento.";
      if (e.toString().contains("503") || e.toString().contains("available")) {
        errorMessage = "Os servidores de Inteligência Artificial do Google estão superlotados no momento. Por favor, tente abrir o devocional novamente em alguns minutos.";
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
        _generatedContent = """
**Atenção:** 
Serviço Indisponível

**Motivo:** 
$errorMessage

**Apoio Exegético:** 
Infelizmente a conexão com os servidores da Inteligência Artificial falhou ou está congestionada.

**Aplicação na Vida Pessoal:**
Tente fechar a tela e abrir novamente daqui a pouco para gerar o estudo deste versículo!

**Versículos Relacionados:**
Não disponíveis no momento.
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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isStudy ? 'Estudo Bíblico' : 'Devocional Diário', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  image: const NetworkImage('https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=800&auto=format&fit=crop'),
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
                  InkWell(
                    onTap: () => _openBibleReference(context, widget.verseReference),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        children: [
                          Text(
                            '"${widget.verseText.replaceAll('"', '')}"',
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.menu_book, color: AppColors.goldBright, size: 14),
                                const SizedBox(width: 8),
                                Text(
                                  widget.verseReference.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.goldBright,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Área de Conteúdo Gerado
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
              child: _buildContent(),
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
        // Drop Cap & Exegesis
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: exegesis.isNotEmpty ? exegesis[0].toUpperCase() : '',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDeep,
                  height: 1.0,
                ),
              ),
              TextSpan(
                text: exegesis.length > 1 ? exegesis.substring(1).replaceAll('*', '') : '',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  color: AppColors.ink,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Context Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (author != "Não informado") _buildContextTag(Icons.person, author),
            if (year != "Não informado") _buildContextTag(Icons.calendar_month, year),
            if (location != "Não informado") _buildContextTag(Icons.location_on, location),
            if (target != "Não informado") _buildContextTag(Icons.group, target),
          ],
        ),

        const SizedBox(height: 32),
        const Divider(color: AppColors.goldBright, thickness: 1.5),
        const SizedBox(height: 32),

        // Aplicação Pessoal
        const Text(
          'Aplicação Pessoal',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.navyDeep,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          application.replaceAll('*', ''),
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            color: AppColors.ink,
            height: 1.8,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Versículos Relacionados
        if (relatedVerses != "Não informado" && relatedVerses.isNotEmpty) ...[
          const Text(
            'Leitura Adicional',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: AppColors.navyDeep,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: relatedVerses.split(RegExp(r"[,\n]")).map((v) {
              final verseRef = v.replaceAll('*', '').replaceAll('-', '').trim();
              if (verseRef.isEmpty) return const SizedBox.shrink();
              return ActionChip(
                label: Text(verseRef, style: const TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: AppColors.navyDeep, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onPressed: () => _openBibleReference(context, verseRef),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildContextTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(icon, size: 14, color: AppColors.navyDeep),
              ),
            ),
            TextSpan(
              text: label,
              style: const TextStyle(fontSize: 12, color: AppColors.navyDeep, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBibleReference(BuildContext context, String reference) async {
    try {
      final parts = reference.split(':');
      if (parts.isEmpty) return;
      
      final bookAndChapter = parts[0].trim();
      final lastSpace = bookAndChapter.lastIndexOf(' ');
      if (lastSpace == -1) return;
      
      final bookName = bookAndChapter.substring(0, lastSpace).trim();
      final chapterStr = bookAndChapter.substring(lastSpace + 1).trim();
      final chapterNum = int.tryParse(chapterStr) ?? 1;

      int? targetVerse;
      if (parts.length > 1) {
        final versePart = parts[1].split('-').first.replaceAll(RegExp(r'[^0-9]'), '');
        targetVerse = int.tryParse(versePart);
      }

      // Mostrar um loading rápido
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.goldBright)),
      );

      // Carregar Bíblia
      final jsonString = await rootBundle.loadString('assets/biblia_jfa.json');
      final data = json.decode(jsonString) as List<dynamic>;
      
      // Encontrar livro
      final book = data.firstWhere(
        (b) => b['name'].toString().toLowerCase().replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ê', 'e') 
            == bookName.toLowerCase().replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ê', 'e'),
        orElse: () => null,
      );

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
                initialVerse: targetVerse,
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir o versículo.')),
        );
      }
    }
  }

}
