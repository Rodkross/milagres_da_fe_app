with open('lib/main.dart', 'r') as f:
    content = f.read()

import re

# Add photoUrl to _EscalaData
old_data_class = """class _EscalaData {
  const _EscalaData({
    required this.role,
    required this.name,
    required this.icon,
  });

  final String role;
  final String name;
  final IconData icon;
}"""

new_data_class = """class _EscalaData {
  const _EscalaData({
    required this.role,
    required this.name,
    required this.icon,
    this.photoUrl,
  });

  final String role;
  final String name;
  final IconData icon;
  final String? photoUrl;
}"""

content = content.replace(old_data_class, new_data_class)

# Update EscalaData creation
old_escala_create = """                          data: _EscalaData(
                            role: item['role'] ?? '',
                            name: item['name'] ?? '',
                            icon: Icons.person_outline,
                          ),"""
new_escala_create = """                          data: _EscalaData(
                            role: item['role'] ?? '',
                            name: item['name'] ?? '',
                            icon: Icons.person_outline,
                            photoUrl: item['photoUrl'],
                          ),"""
content = content.replace(old_escala_create, new_escala_create)

# Update _EscalaCard UI
old_escala_card_avatar = """          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.royal],
              ),
            ),
            child: Icon(data.icon, color: AppColors.goldBright, size: 24),
          ),"""

new_escala_card_avatar = """          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.royal],
              ),
              image: (data.photoUrl != null && data.photoUrl!.isNotEmpty)
                  ? DecorationImage(image: NetworkImage(data.photoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: (data.photoUrl == null || data.photoUrl!.isEmpty)
                ? Icon(data.icon, color: AppColors.goldBright, size: 24)
                : null,
          ),"""
content = content.replace(old_escala_card_avatar, new_escala_card_avatar)


with open('lib/main.dart', 'w') as f:
    f.write(content)
