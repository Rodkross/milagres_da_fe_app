with open('lib/screens/perfil_screen.dart', 'r') as f:
    content = f.read()

# Add _gender state
old_vars = """  DateTime? _conversionDate;
  DateTime? _baptismDate;

  bool _isLoading = true;"""
new_vars = """  DateTime? _conversionDate;
  DateTime? _baptismDate;
  String _gender = 'Masculino';

  bool _isLoading = true;"""
content = content.replace(old_vars, new_vars)

# Load _gender
old_load = """        if (data.containsKey('photoUrl') && data['photoUrl'] != null) {
          _photoUrl = data['photoUrl'];
        }
        _phoneCtrl.text = data['phone'] ?? '';"""
new_load = """        if (data.containsKey('photoUrl') && data['photoUrl'] != null) {
          _photoUrl = data['photoUrl'];
        }
        _gender = data['gender'] ?? 'Masculino';
        _phoneCtrl.text = data['phone'] ?? '';"""
content = content.replace(old_load, new_load)

# Save _gender
old_save = """      final userData = {
        'phone': _phoneCtrl.text,"""
new_save = """      final userData = {
        'gender': _gender,
        'phone': _phoneCtrl.text,"""
content = content.replace(old_save, new_save)

# UI for Gender
old_ui = """                          _buildSectionCard(
                            title: 'Dados Pessoais',
                            icon: Icons.badge_outlined,
                            children: [
                              TextFormField(
                                controller: _nameCtrl,"""
new_ui = """                          _buildSectionCard(
                            title: 'Dados Pessoais',
                            icon: Icons.badge_outlined,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: _inputDecoration('Sexo', icon: Icons.person_outline),
                                items: const [
                                  DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                                  DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _gender = val);
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameCtrl,"""
content = content.replace(old_ui, new_ui)

with open('lib/screens/perfil_screen.dart', 'w') as f:
    f.write(content)
