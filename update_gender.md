# Update Gender Plan

1. **`lib/screens/login_screen.dart`**:
   - Add a dropdown for `Sexo` (`Masculino`, `Feminino`) during registration.
   - Default to `Masculino`.
   - Save `gender: _selectedGender` to Firestore in `_submit()`.

2. **`lib/screens/perfil_screen.dart`**:
   - Load `gender` from Firestore in `_loadUserData()`.
   - Add a Dropdown to edit `Sexo`.
   - Save `gender` to Firestore in `_saveProfile()`.

3. **`lib/main.dart` (`_TopBar`)**:
   - Extract `eccTitle` and `gender` from Firestore `data`.
   - Resolve `eccTitle` based on `gender`.
   - Display the resolved title.

4. **`lib/screens/member_details_screen.dart`**:
   - Change Dropdown options for `eccTitle` to base titles: `'Visitante', 'Membro', 'Obreiro', 'Diácono', 'Presbítero', 'Pastor'`.
   - (Optional) Show resolved title if we know the user's gender, but base title for saving is fine.

Resolution Logic:
```dart
String resolveTitle(String title, String gender) {
  if (gender == 'Feminino') {
    switch (title) {
      case 'Obreiro': return 'Obreira';
      case 'Diácono': return 'Diaconisa';
      case 'Presbítero': return 'Presbítera';
      case 'Pastor': return 'Pastora';
      case 'Obreiro(a)': return 'Obreira'; // Fallback for old data
      case 'Diácono / Diaconisa': return 'Diaconisa'; // Fallback
      case 'Presbítero(a)': return 'Presbítera'; // Fallback
      case 'Pastor(a)': return 'Pastora'; // Fallback
    }
  } else { // Masculino or missing
    switch (title) {
      case 'Obreiro(a)': return 'Obreiro';
      case 'Diácono / Diaconisa': return 'Diácono';
      case 'Presbítero(a)': return 'Presbítero';
      case 'Pastor(a)': return 'Pastor';
    }
  }
  return title; // Default (Membro, Visitante, or already resolved)
}
```
