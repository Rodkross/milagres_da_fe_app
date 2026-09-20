import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../main.dart'; // Para acessar AppColors

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  // Controladores de texto
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _complementCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();

  // Datas
  DateTime? _birthDate;
  DateTime? _conversionDate;
  DateTime? _baptismDate;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _nameCtrl.text = user.displayName ?? '';
      _photoUrl = user.photoURL;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _phoneCtrl.text = data['phone'] ?? '';
        _aboutCtrl.text = data['aboutMe'] ?? '';
        
        if (data['birthDate'] != null) _birthDate = (data['birthDate'] as Timestamp).toDate();
        if (data['conversionDate'] != null) _conversionDate = (data['conversionDate'] as Timestamp).toDate();
        if (data['baptismDate'] != null) _baptismDate = (data['baptismDate'] as Timestamp).toDate();
        
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          _cepCtrl.text = address['cep'] ?? '';
          _addressCtrl.text = address['street'] ?? '';
          _numberCtrl.text = address['number'] ?? '';
          _complementCtrl.text = address['complement'] ?? '';
          _neighborhoodCtrl.text = address['neighborhood'] ?? '';
          _cityCtrl.text = address['city'] ?? '';
          _stateCtrl.text = address['state'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
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
  }

  Future<void> _searchCep() async {
    final cep = _cepCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == null) {
          setState(() {
            _addressCtrl.text = data['logradouro'] ?? '';
            _neighborhoodCtrl.text = data['bairro'] ?? '';
            _cityCtrl.text = data['localidade'] ?? '';
            _stateCtrl.text = data['uf'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Erro no ViaCEP: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navyDeep,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => onSelected(picked));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final user = _auth.currentUser!;
      
      if (user.displayName != _nameCtrl.text) {
        await user.updateDisplayName(_nameCtrl.text);
      }

      final userData = {
        'phone': _phoneCtrl.text,
        'aboutMe': _aboutCtrl.text,
        'birthDate': _birthDate != null ? Timestamp.fromDate(_birthDate!) : null,
        'conversionDate': _conversionDate != null ? Timestamp.fromDate(_conversionDate!) : null,
        'baptismDate': _baptismDate != null ? Timestamp.fromDate(_baptismDate!) : null,
        'address': {
          'cep': _cepCtrl.text,
          'street': _addressCtrl.text,
          'number': _numberCtrl.text,
          'complement': _complementCtrl.text,
          'neighborhood': _neighborhoodCtrl.text,
          'city': _cityCtrl.text,
          'state': _stateCtrl.text,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volta pra tela anterior
      }
    } catch (e) {
      debugPrint('Erro ao salvar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar perfil.'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // --- COMPONENTES DE DESIGN ---

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.muted),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.navy) : null,
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.goldBright, width: 2),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.goldBright, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value, Function(DateTime) onUpdate) {
    return InkWell(
      onTap: () => _selectDate(context, value, onUpdate),
      child: InputDecorator(
        decoration: _inputDecoration(label, icon: Icons.calendar_today_rounded),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'DD/MM/AAAA',
          style: TextStyle(
            color: value != null ? AppColors.ink : AppColors.muted,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navyDeep,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldBright)) 
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Cabeçalho de Fundo Azul com o Avatar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 32, top: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.navyDeep,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.goldBright,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 56,
                                  backgroundColor: Colors.white,
                                  backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                                  child: _photoUrl == null 
                                      ? const Icon(Icons.person, size: 50, color: AppColors.navy) 
                                      : null,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 4, right: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: const Icon(Icons.camera_alt, size: 18, color: AppColors.navyDeep),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Toque para alterar a foto',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // Formulário de Edição
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildSectionCard(
                            title: 'Dados Pessoais',
                            icon: Icons.badge_outlined,
                            children: [
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: _inputDecoration('Nome Completo', icon: Icons.person_outline),
                                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneCtrl,
                                decoration: _inputDecoration('Telefone', icon: Icons.phone_outlined),
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),

                          _buildSectionCard(
                            title: 'Datas Importantes',
                            icon: Icons.event_available_outlined,
                            children: [
                              _buildDateField('Nascimento', _birthDate, (d) => _birthDate = d),
                              const SizedBox(height: 16),
                              _buildDateField('Conversão', _conversionDate, (d) => _conversionDate = d),
                              const SizedBox(height: 16),
                              _buildDateField('Batismo nas Águas', _baptismDate, (d) => _baptismDate = d),
                            ],
                          ),

                          _buildSectionCard(
                            title: 'Endereço',
                            icon: Icons.location_on_outlined,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: _cepCtrl,
                                      decoration: _inputDecoration('CEP', icon: Icons.map_outlined),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) {
                                        if (v.length >= 8) _searchCep();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: _stateCtrl,
                                      decoration: _inputDecoration('UF'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cityCtrl,
                                decoration: _inputDecoration('Cidade'),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: _addressCtrl,
                                      decoration: _inputDecoration('Logradouro'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: _numberCtrl,
                                      decoration: _inputDecoration('Nº'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _complementCtrl,
                                      decoration: _inputDecoration('Complemento'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _neighborhoodCtrl,
                                      decoration: _inputDecoration('Bairro'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          _buildSectionCard(
                            title: 'Sobre Mim',
                            icon: Icons.edit_note_rounded,
                            children: [
                              TextFormField(
                                controller: _aboutCtrl,
                                decoration: _inputDecoration('Biografia ou Ministério').copyWith(
                                  prefixIcon: null,
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          
                          // Botão Salvar
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldBright,
                                foregroundColor: AppColors.navyDeep,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                              ),
                              onPressed: _isSaving ? null : _saveProfile,
                              icon: _isSaving 
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.navyDeep, strokeWidth: 2))
                                  : const Icon(Icons.check_circle_outline, size: 24),
                              label: Text(
                                _isSaving ? 'Salvando...' : 'Salvar Perfil',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
