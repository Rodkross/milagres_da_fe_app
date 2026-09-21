with open('lib/screens/perfil_screen.dart', 'r') as f:
    content = f.read()

# 1. Update PerfilScreen constructor
old_constructor = """class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});"""
new_constructor = """class PerfilScreen extends StatefulWidget {
  final String? adminEditUserId;
  const PerfilScreen({super.key, this.adminEditUserId});"""
content = content.replace(old_constructor, new_constructor)

# 2. Update _loadUserData
old_load = """  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _nameCtrl.text = user.displayName ?? '';
      _photoUrl = user.photoURL;

      final doc = await _firestore.collection('users').doc(user.uid).get();"""

new_load = """  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final isEditingOther = widget.adminEditUserId != null;
      final targetUid = widget.adminEditUserId ?? user.uid;

      if (!isEditingOther) {
        _nameCtrl.text = user.displayName ?? '';
        _photoUrl = user.photoURL;
      }

      final doc = await _firestore.collection('users').doc(targetUid).get();
      if (isEditingOther && doc.exists) {
        _nameCtrl.text = doc.data()!['name'] ?? '';
      }"""
content = content.replace(old_load, new_load)

# 3. Update _pickAndUploadImage
old_upload = """    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser!;
      final file = File(pickedFile.path);
      final ref = _storage.ref().child('user_avatars/${user.uid}.jpg');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      await user.updatePhotoURL(downloadUrl);
      await _firestore.collection('users').doc(user.uid).set({'photoUrl': downloadUrl}, SetOptions(merge: true));"""

new_upload = """    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser!;
      final isEditingOther = widget.adminEditUserId != null;
      final targetUid = widget.adminEditUserId ?? user.uid;
      
      final file = File(pickedFile.path);
      final ref = _storage.ref().child('user_avatars/${targetUid}.jpg');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      if (!isEditingOther) {
        await user.updatePhotoURL(downloadUrl);
      }
      await _firestore.collection('users').doc(targetUid).set({'photoUrl': downloadUrl}, SetOptions(merge: true));"""
content = content.replace(old_upload, new_upload)

# 4. Update _saveProfile
old_save = """  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final user = _auth.currentUser!;
      
      if (user.displayName != _nameCtrl.text) {
        await user.updateDisplayName(_nameCtrl.text);
      }

      final userData = {"""
new_save = """  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final user = _auth.currentUser!;
      final isEditingOther = widget.adminEditUserId != null;
      final targetUid = widget.adminEditUserId ?? user.uid;
      
      if (!isEditingOther && user.displayName != _nameCtrl.text) {
        await user.updateDisplayName(_nameCtrl.text);
      }

      final userData = {
        'name': _nameCtrl.text,"""
content = content.replace(old_save, new_save)

old_save_firestore = """      };

      await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));"""
new_save_firestore = """      };

      await _firestore.collection('users').doc(targetUid).set(userData, SetOptions(merge: true));"""
content = content.replace(old_save_firestore, new_save_firestore)

with open('lib/screens/perfil_screen.dart', 'w') as f:
    f.write(content)
