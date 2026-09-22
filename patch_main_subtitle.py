with open('lib/main.dart', 'r') as f:
    content = f.read()

import re

old_block = """                final cultoName = data['cultoName'] ?? '';
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
                      ),"""

new_block = """                final cultoName = data['cultoName'] ?? '';
                final assignments = List<Map<String, dynamic>>.from(data['assignments'] ?? []);
                
                if (assignments.isEmpty) {
                   return const SizedBox.shrink();
                }

                String cleanTitle = cultoName;
                String timeStr = "";
                if (cultoName.contains('•')) {
                  final parts = cultoName.split('•');
                  cleanTitle = parts[0].trim();
                  if (parts[1].contains(',')) {
                    timeStr = parts[1].split(',').last.trim();
                  } else {
                    timeStr = parts[1].trim().split(' ').last;
                  }
                }
                
                String dateFormatted = DateFormat("EEEE, dd/MM", "pt_BR").format(cultoDate);
                if (dateFormatted.isNotEmpty) {
                  dateFormatted = dateFormatted[0].toUpperCase() + dateFormatted.substring(1);
                }
                final subtitleFormatted = timeStr.isNotEmpty ? '$cleanTitle • $dateFormatted às $timeStr' : '$cleanTitle • $dateFormatted';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _SectionHeader(
                        title: 'Escala de Serviço',
                        subtitle: subtitleFormatted,
                        actionLabel: '',
                      ),"""

content = content.replace(old_block, new_block)

# Since DateFormat requires intl, check if intl is imported in main.dart
if "import 'package:intl/intl.dart';" not in content:
    content = content.replace("import 'package:flutter_localizations/flutter_localizations.dart';", "import 'package:flutter_localizations/flutter_localizations.dart';\nimport 'package:intl/intl.dart';")

with open('lib/main.dart', 'w') as f:
    f.write(content)
