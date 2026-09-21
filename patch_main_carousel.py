with open('lib/main.dart', 'r') as f:
    content = f.read()

old_carousel = """              child: _HeroBanner(items: programacaoAtual),"""

new_carousel = """              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('cultos').orderBy('order').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final docs = snapshot.data?.docs ?? [];
                  
                  // Se não houver nenhum culto, usa os itens estáticos como fallback provisório,
                  // ou retorna uma box vazia.
                  if (docs.isEmpty) {
                    return const _HeroBanner(items: programacaoAtual);
                  }

                  final List<ProgramacaoItem> items = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ProgramacaoItem(
                      titulo: data['title'] ?? 'Culto',
                      data: '${data['day'] ?? ''} • ${data['time'] ?? ''}',
                      imageUrl: data['imageUrl'],
                    );
                  }).toList();

                  return _HeroBanner(items: items);
                },
              ),"""

content = content.replace(old_carousel, new_carousel)

with open('lib/main.dart', 'w') as f:
    f.write(content)
