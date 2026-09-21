import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço responsável por toda a comunicação com o Firebase Authentication.
///
/// Centraliza login, cadastro, logout e o estado de autenticação para que a
/// interface nunca precise falar diretamente com o SDK do Firebase.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore}) 
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Usuário atualmente autenticado (ou `null`).
  User? get currentUser => _auth.currentUser;

  /// Fluxo que emite o usuário sempre que o estado de login muda.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Cria uma conta com e-mail e senha e define o nome de exibição.
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    required String ecclesiasticalTitle,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final displayName = name.trim();
    if (displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
    }
    
    // Grava o perfil no Firestore com os níveis de acesso
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': displayName,
        'email': email.trim(),
        'ecclesiasticalTitle': ecclesiasticalTitle,
        'departmentAccess': 'membresia', // Padrão de segurança
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    
    return credential;
  }

  /// Autentica com e-mail e senha.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Envia um e-mail de redefinição de senha.
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Encerra a sessão atual.
  Future<void> signOut() => _auth.signOut();

  /// Converte as exceções do Firebase em mensagens amigáveis em português.
  static String messageFor(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'E-mail inválido. Verifique e tente novamente.';
        case 'user-disabled':
          return 'Esta conta foi desativada.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'email-already-in-use':
          return 'Este e-mail já está cadastrado.';
        case 'weak-password':
          return 'A senha é muito fraca. Use ao menos 6 caracteres.';
        case 'too-many-requests':
          return 'Muitas tentativas. Aguarde alguns minutos e tente de novo.';
        case 'network-request-failed':
          return 'Falha de conexão. Verifique sua internet.';
        case 'operation-not-allowed':
          return 'Login por e-mail/senha não está ativado no Firebase.';
        default:
          return 'Não foi possível concluir. Tente novamente.';
      }
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}
