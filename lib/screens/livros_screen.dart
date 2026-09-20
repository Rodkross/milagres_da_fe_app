import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../main.dart'; // Para acessar AppColors

class BookData {
  final String title;
  final String author;
  final String coverUrl;
  final String pdfUrl;
  final String description;

  const BookData({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.pdfUrl,
    required this.description,
  });
}

// Mockup de livros.
// Dica: No Google Drive, o link direto do PDF segue este formato:
// https://drive.google.com/uc?export=download&id=ID_DO_ARQUIVO
final List<BookData> _livrosMock = [
  const BookData(
    title: 'Sermões de Spurgeon sobre o Sermão do Monte',
    author: 'C. H. Spurgeon',
    coverUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=600&auto=format&fit=crop', // Capa genérica
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1UgbQ1I-cMh2uoZATkiSFyj952QPzYZy0',
    description: 'Um estudo profundo e abençoado de Spurgeon sobre um dos sermões mais famosos de Jesus.',
  ),
  const BookData(
    title: 'As Sete Igrejas do Apocalipse',
    author: 'Editora RTM',
    coverUrl: 'https://images.unsplash.com/photo-1495640388908-05fa85288e61?q=80&w=600&auto=format&fit=crop', // Outra capa genérica
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1bUOGUuJBNeuJKUTbDgGUZDBIWSAgKdY5',
    description: 'Uma análise exegética e espiritual sobre as cartas enviadas por Jesus às sete igrejas na Ásia.',
  ),
];

class LivrosScreen extends StatelessWidget {
  const LivrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Biblioteca', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _livrosMock.length,
        itemBuilder: (context, index) {
          final book = _livrosMock[index];
          return _BookCard(book: book);
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final BookData book;

  void _abrirLeitor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfReaderScreen(
          title: book.title,
          pdfUrl: book.pdfUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Capa do Livro
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: Image.network(
              book.coverUrl,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          
          // Informações
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Por: ${book.author}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldBright,
                        foregroundColor: AppColors.navyDeep,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _abrirLeitor(context),
                      icon: const Icon(Icons.menu_book, size: 18),
                      label: const Text('Ler Agora', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PdfReaderScreen extends StatelessWidget {
  const PdfReaderScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  final String title;
  final String pdfUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // O visualizador de PDF carrega o arquivo a partir da URL.
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
