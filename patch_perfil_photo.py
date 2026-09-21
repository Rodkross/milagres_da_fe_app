with open('lib/screens/perfil_screen.dart', 'r') as f:
    content = f.read()

old_load = """      if (doc.exists) {
        final data = doc.data()!;
        _phoneCtrl.text = data['phone'] ?? '';"""
new_load = """      if (doc.exists) {
        final data = doc.data()!;
        if (data.containsKey('photoUrl') && data['photoUrl'] != null) {
          _photoUrl = data['photoUrl'];
        }
        _phoneCtrl.text = data['phone'] ?? '';"""

content = content.replace(old_load, new_load)

with open('lib/screens/perfil_screen.dart', 'w') as f:
    f.write(content)
