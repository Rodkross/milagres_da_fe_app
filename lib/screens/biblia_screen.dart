import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../main.dart'; // for AppColors
import 'devocional_screen.dart';

class BibliaScreen extends StatefulWidget {
  const BibliaScreen({super.key});

  @override
  State<BibliaScreen> createState() => _BibliaScreenState();
}

class _BibliaScreenState extends State<BibliaScreen> {
  List<dynamic> _bibleData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  Future<void> _loadBible() async {
    try {
      final jsonString = await rootBundle.loadString('assets/biblia_jfa.json');
      final data = json.decode(jsonString) as List<dynamic>;
      setState(() {
        _bibleData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar a bíblia: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Bíblia Sagrada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bibleData.isEmpty
              ? const Center(child: Text('Erro ao carregar a Bíblia.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _bibleData.length,
                  itemBuilder: (context, index) {
                    final book = _bibleData[index];
                    return _BookCard(
                      name: book['name'],
                      abbrev: book['abbrev'],
                      chapters: book['chapters'] as List<dynamic>,
                    );
                  },
                ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.name,
    required this.abbrev,
    required this.chapters,
  });

  final String name;
  final String abbrev;
  final List<dynamic> chapters;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          name,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.gold),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapterSelectionScreen(
                bookName: name,
                chapters: chapters,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChapterSelectionScreen extends StatelessWidget {
  const ChapterSelectionScreen({
    super.key,
    required this.bookName,
    required this.chapters,
  });

  final String bookName;
  final List<dynamic> chapters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(bookName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapterNum = index + 1;
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerseSelectionScreen(
                    bookName: bookName,
                    chapterNum: chapterNum,
                    verses: chapters[index] as List<dynamic>,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  '$chapterNum',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class VerseSelectionScreen extends StatelessWidget {
  const VerseSelectionScreen({
    super.key,
    required this.bookName,
    required this.chapterNum,
    required this.verses,
  });

  final String bookName;
  final int chapterNum;
  final List<dynamic> verses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text('$bookName $chapterNum', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final verseNum = index + 1;
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadingScreen(
                    bookName: bookName,
                    chapterNum: chapterNum,
                    verses: verses,
                    initialVerse: verseNum,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  '$verseNum',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({
    super.key,
    required this.bookName,
    required this.chapterNum,
    required this.verses,
    this.initialVerse,
  });

  final String bookName;
  final int chapterNum;
  final List<dynamic> verses;
  final int? initialVerse;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  double _fontSize = 17.0;
  final GlobalKey _targetVerseKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_targetVerseKey.currentContext != null) {
          Scrollable.ensureVisible(
            _targetVerseKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.2, // Puts it near the top
          );
        }
      });
    }
  }

  void _changeFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(14.0, 32.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.bookName} ${widget.chapterNum}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Diminuir Fonte',
            onPressed: () => _changeFontSize(-2.0),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'Aumentar Fonte',
            onPressed: () => _changeFontSize(2.0),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(widget.verses.length, (index) {
            final verseNum = index + 1;
            final text = widget.verses[index].toString();
            final isTarget = widget.initialVerse == verseNum;

            return Container(
              key: isTarget ? _targetVerseKey : null,
              margin: const EdgeInsets.only(bottom: 12),
              padding: isTarget ? const EdgeInsets.all(8) : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: isTarget ? AppColors.goldBright.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: _fontSize,
                          height: 1.5,
                          fontFamily: 'Georgia',
                        ),
                        children: [
                          TextSpan(
                            text: '$verseNum ',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: _fontSize - 4,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [FontFeature.superscripts()],
                            ),
                          ),
                          TextSpan(text: text),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DevocionalScreen(
                            verseText: text,
                            verseReference: '${widget.bookName} ${widget.chapterNum}:$verseNum',
                            isStudy: true,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 6, right: 2, top: 2, bottom: 2),
                      color: Colors.transparent,
                      child: const Icon(Icons.auto_awesome, color: AppColors.goldBright, size: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}