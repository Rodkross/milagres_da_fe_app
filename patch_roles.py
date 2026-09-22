with open('lib/screens/admin_escala_screen.dart', 'r') as f:
    content = f.read()

old_roles = """    final roles = [
      'Recepção',
      'Altar e Oferta',
      'Som e Multimídia',
      'Limpeza e Organização',
      'Cantina / Conveniência',
      'Estacionamento',
      'Louvor',
      'Portaria',
      'Segurança',
      'Direção do Culto',
      'Pregação da Palavra'
    ];"""

new_roles = """    final roles = [
      'Altar e Oferta',
      'Luzes Recepção',
      'Som e Mídia',
      'Cantina',
      'Direção do Culto',
      'Palavra Devocional',
      'Palavra Ofertória',
      'Pregação'
    ];"""

content = content.replace(old_roles, new_roles)

with open('lib/screens/admin_escala_screen.dart', 'w') as f:
    f.write(content)
