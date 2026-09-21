with open('lib/screens/login_screen.dart', 'r') as f:
    content = f.read()

# Add _selectedGender
old_vars = """  String? _errorMessage;
  String _selectedTitle = 'Membro';

  final List<String> _titles = ["""
new_vars = """  String? _errorMessage;
  String _selectedTitle = 'Membro';
  String _selectedGender = 'Masculino';

  final List<String> _titles = ["""
content = content.replace(old_vars, new_vars)

# Add Dropdown for Gender
old_dropdowns = """              _DropdownField(
                label: 'Selecione quem é você',
                value: _selectedTitle,
                titles: _titles,
                onTitleChanged: (val) {
                  if (val != null) setState(() => _selectedTitle = val);
                },
              ),
              const SizedBox(height: 16),"""
new_dropdowns = """              Row(
                children: [
                  Expanded(
                    child: _DropdownField(
                      label: 'Vínculo',
                      value: _selectedTitle,
                      titles: _titles,
                      onTitleChanged: (val) {
                        if (val != null) setState(() => _selectedTitle = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField(
                      label: 'Sexo',
                      value: _selectedGender,
                      titles: const ['Masculino', 'Feminino'],
                      onTitleChanged: (val) {
                        if (val != null) setState(() => _selectedGender = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),"""
content = content.replace(old_dropdowns, new_dropdowns)

# Save gender to Firestore
old_save = """        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'ecclesiasticalTitle': _selectedTitle,
          'departmentAccess': defaultAccess,
          'createdAt': FieldValue.serverTimestamp(),
        });"""
new_save = """        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'gender': _selectedGender,
          'ecclesiasticalTitle': _selectedTitle,
          'departmentAccess': defaultAccess,
          'createdAt': FieldValue.serverTimestamp(),
        });"""
content = content.replace(old_save, new_save)

with open('lib/screens/login_screen.dart', 'w') as f:
    f.write(content)
