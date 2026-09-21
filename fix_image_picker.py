with open('lib/screens/perfil_screen.dart', 'r') as f:
    content = f.read()

old_picker_func = """  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser!;
      final file = File(pickedFile.path);
      final ref = _storage.ref().child('user_avatars/${user.uid}.jpg');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      await user.updatePhotoURL(downloadUrl);
      setState(() => _photoUrl = downloadUrl);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto atualizada com sucesso!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint('Erro ao subir imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao atualizar foto.'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }"""

new_picker_func = """  Future<void> _pickAndUploadImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Escolha a origem da foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.navy),
                title: const Text('Câmera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.navy),
                title: const Text('Galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser!;
      final file = File(pickedFile.path);
      final ref = _storage.ref().child('user_avatars/${user.uid}.jpg');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      await user.updatePhotoURL(downloadUrl);
      setState(() => _photoUrl = downloadUrl);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto atualizada com sucesso!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint('Erro ao subir imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao atualizar foto.'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }"""

content = content.replace(old_picker_func, new_picker_func)

with open('lib/screens/perfil_screen.dart', 'w') as f:
    f.write(content)
