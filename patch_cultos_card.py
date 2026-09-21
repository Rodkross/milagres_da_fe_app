with open('lib/screens/cultos_screen.dart', 'r') as f:
    content = f.read()

# Pass imageUrl from Firestore
old_list_item = """              return _CultoCard(
                title: data['title'] ?? '',
                day: data['day'] ?? '',
                time: data['time'] ?? '',
                location: data['location'] ?? '',
              );"""
new_list_item = """              return _CultoCard(
                title: data['title'] ?? '',
                day: data['day'] ?? '',
                time: data['time'] ?? '',
                location: data['location'] ?? '',
                imageUrl: data['imageUrl'],
              );"""
content = content.replace(old_list_item, new_list_item)


# Move Image to the right and render image
old_row = """        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área reservada para a imagem
            Container(
              width: 110,
              decoration: const BoxDecoration(
                color: AppColors.surface, // Cor de fundo do placeholder
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.muted,
                  size: 32,
                ),
              ),
            ),
            // Área de conteúdo
            Expanded(
              child: Padding("""

new_row = """        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área de conteúdo
            Expanded(
              child: Padding("""

content = content.replace(old_row, new_row)


old_end_row = """                ),
              ),
            ),
          ],
        ),"""

new_end_row = """                ),
              ),
            ),
            // Área da imagem (direita)
            Container(
              width: 110,
              decoration: BoxDecoration(
                color: AppColors.surface, // Cor de fundo
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.muted,
                        size: 32,
                      ),
                    )
                  : null,
            ),
          ],
        ),"""

content = content.replace(old_end_row, new_end_row)

with open('lib/screens/cultos_screen.dart', 'w') as f:
    f.write(content)
