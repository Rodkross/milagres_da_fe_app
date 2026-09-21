import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart'; // Para AppColors

class AdminCultosScreen extends StatelessWidget {
  const AdminCultosScreen({super.key});

  Future<void> _showCultoDialog(BuildContext context, {DocumentSnapshot? doc}) async {
    final isEditing = doc != null;
    final data = isEditing ? doc.data() as Map<String, dynamic> : null;

    final titleCtrl = TextEditingController(text: data?['title'] ?? '');
    final dayCtrl = TextEditingController(text: data?['day'] ?? '');
    final timeCtrl = TextEditingController(text: data?['time'] ?? '');
    final locationCtrl = TextEditingController(text: data?['location'] ?? 'Igreja');
    final orderCtrl = TextEditingController(text: (data?['order'] ?? 0).toString());
    
    String? imageUrl = data?['imageUrl'];
    bool isUploading = false;
    File? tempImage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            
            Future<void> _pickImage() async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (pickedFile != null) {
                setState(() => tempImage = File(pickedFile.path));
              }
            }

            return AlertDialog(
              title: Text(isEditing ? 'Editar Culto' : 'Novo Culto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: isUploading ? null : _pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: tempImage != null
                              ? DecorationImage(image: FileImage(tempImage!), fit: BoxFit.cover)
                              : (imageUrl != null && imageUrl!.isNotEmpty)
                                  ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: (tempImage == null && (imageUrl == null || imageUrl!.isEmpty))
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.grey, size: 32),
                                  SizedBox(height: 8),
                                  Text('Adicionar Imagem', style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título (ex: Culto de Libertação)')),
                    TextField(controller: dayCtrl, decoration: const InputDecoration(labelText: 'Dia (ex: Toda Quinta)')),
                    TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Horário (ex: 19:00)')),
                    TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Local (ex: Igreja)')),
                    TextField(
                      controller: orderCtrl, 
                      decoration: const InputDecoration(labelText: 'Ordem de exibição (ex: 1)'),
                      keyboardType: TextInputType.number,
                    ),
                    if (isUploading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isUploading ? null : () async {
                    setState(() => isUploading = true);
                    
                    try {
                      String? finalImageUrl = imageUrl;
                      
                      // Upload da nova imagem se houver
                      if (tempImage != null) {
                        final filename = 'cultos/${DateTime.now().millisecondsSinceEpoch}.jpg';
                        final ref = FirebaseStorage.instance.ref().child(filename);
                        await ref.putFile(tempImage!);
                        finalImageUrl = await ref.getDownloadURL();
                      }

                      final order = int.tryParse(orderCtrl.text.trim()) ?? 0;
                      final cultoData = {
                        'title': titleCtrl.text.trim(),
                        'day': dayCtrl.text.trim(),
                        'time': timeCtrl.text.trim(),
                        'location': locationCtrl.text.trim(),
                        'order': order,
                        'imageUrl': finalImageUrl,
                      };

                      if (isEditing) {
                        await FirebaseFirestore.instance.collection('cultos').doc(doc.id).update(cultoData);
                      } else {
                        await FirebaseFirestore.instance.collection('cultos').add(cultoData);
                      }
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint('Erro ao salvar culto: $e');
                      setState(() => isUploading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldBright, foregroundColor: AppColors.navyDeep),
                  child: const Text('Salvar'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Cultos'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCultoDialog(context),
        backgroundColor: AppColors.goldBright,
        child: const Icon(Icons.add, color: AppColors.navyDeep),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cultos').orderBy('order').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('Nenhum culto cadastrado.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final imgUrl = data['imageUrl'] as String?;
              
              return ListTile(
                leading: imgUrl != null && imgUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(imgUrl, width: 50, height: 50, fit: BoxFit.cover),
                      )
                    : Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${data['day']} às ${data['time']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCultoDialog(context, doc: doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => FirebaseFirestore.instance.collection('cultos').doc(doc.id).delete(),
                    ),
                  ],
                ),
              );
            },
          );
        }
      ),
    );
  }
}
