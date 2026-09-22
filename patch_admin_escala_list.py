with open('lib/screens/admin_escala_screen.dart', 'r') as f:
    content = f.read()

import re

old_list = """                      itemBuilder: (context, index) {
                        final item = assignments[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.goldBright,
                            child: Icon(Icons.person_outline, color: AppColors.navyDeep),
                          ),
                          title: Text(item['role'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item['name'] ?? ''),"""

new_list = """                      itemBuilder: (context, index) {
                        final item = assignments[index];
                        final pUrl = item['photoUrl'] as String?;
                        return ListTile(
                          leading: pUrl != null && pUrl.isNotEmpty
                              ? CircleAvatar(backgroundImage: NetworkImage(pUrl))
                              : const CircleAvatar(
                                  backgroundColor: AppColors.goldBright,
                                  child: Icon(Icons.person_outline, color: AppColors.navyDeep),
                                ),
                          title: Text(item['role'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item['name'] ?? ''),"""

content = content.replace(old_list, new_list)

with open('lib/screens/admin_escala_screen.dart', 'w') as f:
    f.write(content)
