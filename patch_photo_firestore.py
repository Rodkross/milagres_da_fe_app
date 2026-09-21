with open('lib/screens/perfil_screen.dart', 'r') as f:
    content = f.read()

old_upload = """      await user.updatePhotoURL(downloadUrl);
      setState(() => _photoUrl = downloadUrl);"""

new_upload = """      await user.updatePhotoURL(downloadUrl);
      await _firestore.collection('users').doc(user.uid).set({'photoUrl': downloadUrl}, SetOptions(merge: true));
      setState(() => _photoUrl = downloadUrl);"""

content = content.replace(old_upload, new_upload)

with open('lib/screens/perfil_screen.dart', 'w') as f:
    f.write(content)
