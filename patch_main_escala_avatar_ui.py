with open('lib/main.dart', 'r') as f:
    content = f.read()

import re

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
              image: (data.photoUrl != null && data.photoUrl!.isNotEmpty)
                  ? DecorationImage(image: NetworkImage(data.photoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: (data.photoUrl == null || data.photoUrl!.isEmpty)
                ? Icon(data.icon, color: AppColors.goldBright, size: 24)
                : null,
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
            ),
            child: (data.photoUrl != null && data.photoUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(data.photoUrl!, width: 54, height: 54, fit: BoxFit.cover),
                  )
                : Icon(data.icon, color: AppColors.goldBright, size: 24),
          ),"""
content = content.replace(old_escala_card_avatar, new_escala_card_avatar)

with open('lib/main.dart', 'w') as f:
    f.write(content)
