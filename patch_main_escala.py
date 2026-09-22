with open('lib/main.dart', 'r') as f:
    content = f.read()

old_escala_header = """          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 32, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Escala de Serviço',
                subtitle: 'Culto de Libertação • Quinta, 19:00',
                actionLabel: 'Ver tudo',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _EscalaCard(data: _escala[index]),
                ),
                childCount: _escala.length,
              ),
            ),
          ),"""

new_escala_stream = """          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('escala').doc('current').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              
              final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final isDefined = data.containsKey('cultoDate') && data['cultoDate'] != null;
              
              if (!isDefined) {
                return const SliverToBoxAdapter(child: SizedBox.shrink()); // Aguardando nova escala
              }
              
              final cultoDate = (data['cultoDate'] as Timestamp).toDate();
              final expirationDate = DateTime(cultoDate.year, cultoDate.month, cultoDate.day).add(const Duration(days: 1));
              
              if (DateTime.now().isAfter(expirationDate)) {
                return const SliverToBoxAdapter(child: SizedBox.shrink()); // Expirou, sumir da tela inicial
              }

              final cultoName = data['cultoName'] ?? '';
              final assignments = List<Map<String, dynamic>>.from(data['assignments'] ?? []);
              
              if (assignments.isEmpty) {
                 return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return MultiSliver(
                children: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Escala de Serviço',
                        subtitle: '$cultoName',
                        actionLabel: '', // removido ver tudo por enquanto
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final item = assignments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _EscalaCard(
                              data: _EscalaData(
                                role: item['role'] ?? '',
                                name: item['name'] ?? '',
                                icon: Icons.person_outline, // default fixo ou podemos adicionar lógicas depois
                              )
                            ),
                          );
                        },
                        childCount: assignments.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),"""

content = content.replace(old_escala_header, new_escala_stream)

# We need to import sliver_tools or something if we use MultiSliver?
# Wait! MultiSliver is not built-in Flutter. I cannot use MultiSliver unless the package is installed.
# I will use a simple SliverToBoxAdapter containing a Column instead of SliverList, it's easier and safe for small lists.

new_escala_stream_safe = """          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('escala').doc('current').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              
              final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final isDefined = data.containsKey('cultoDate') && data['cultoDate'] != null;
              
              if (!isDefined) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              
              final cultoDate = (data['cultoDate'] as Timestamp).toDate();
              final expirationDate = DateTime(cultoDate.year, cultoDate.month, cultoDate.day).add(const Duration(days: 1));
              
              if (DateTime.now().isAfter(expirationDate)) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              final cultoName = data['cultoName'] ?? '';
              final assignments = List<Map<String, dynamic>>.from(data['assignments'] ?? []);
              
              if (assignments.isEmpty) {
                 return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _SectionHeader(
                        title: 'Escala de Serviço',
                        subtitle: '$cultoName',
                        actionLabel: '',
                      ),
                      const SizedBox(height: 8),
                      ...assignments.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EscalaCard(
                          data: _EscalaData(
                            role: item['role'] ?? '',
                            name: item['name'] ?? '',
                            icon: Icons.person_outline,
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              );
            },
          ),"""

content = content.replace(old_escala_header, new_escala_stream_safe)

# Also I need to remove the StreamBuilder wrapper because `slivers` expects slivers.
# Actually, StreamBuilder is NOT a sliver! Wait, I must use SliverToBoxAdapter with a StreamBuilder inside it, OR use a sliver stream builder if there's one? No, in Flutter, we can't just put a StreamBuilder in a CustomScrollView's slivers array unless we use `SliverToBoxAdapter` as the root of the StreamBuilder.
# Let's fix that.

new_escala_stream_sliver = """          SliverToBoxAdapter(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('escala').doc('current').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                
                final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final isDefined = data.containsKey('cultoDate') && data['cultoDate'] != null;
                
                if (!isDefined) {
                  return const SizedBox.shrink();
                }
                
                final cultoDate = (data['cultoDate'] as Timestamp).toDate();
                final expirationDate = DateTime(cultoDate.year, cultoDate.month, cultoDate.day).add(const Duration(days: 1));
                
                if (DateTime.now().isAfter(expirationDate)) {
                  return const SizedBox.shrink();
                }

                final cultoName = data['cultoName'] ?? '';
                final assignments = List<Map<String, dynamic>>.from(data['assignments'] ?? []);
                
                if (assignments.isEmpty) {
                   return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _SectionHeader(
                        title: 'Escala de Serviço',
                        subtitle: cultoName,
                        actionLabel: '',
                      ),
                      const SizedBox(height: 8),
                      ...assignments.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EscalaCard(
                          data: _EscalaData(
                            role: item['role'] ?? '',
                            name: item['name'] ?? '',
                            icon: Icons.person_outline,
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                );
              },
            ),
          ),"""

content = content.replace(old_escala_header, new_escala_stream_sliver)

with open('lib/main.dart', 'w') as f:
    f.write(content)
