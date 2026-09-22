with open('lib/main.dart', 'r') as f:
    content = f.read()

import re

# Match the entire StreamBuilder<DocumentSnapshot> up to its closing parenthesis
# We'll just replace the whole block.
old_block = re.search(r"          StreamBuilder<DocumentSnapshot>\(.*?            \},.*?          \),", content, re.DOTALL)

if old_block:
    new_block = """          SliverToBoxAdapter(
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
    content = content[:old_block.start()] + new_block + content[old_block.end():]
    
    with open('lib/main.dart', 'w') as f:
        f.write(content)
else:
    print("Could not find StreamBuilder block!")
