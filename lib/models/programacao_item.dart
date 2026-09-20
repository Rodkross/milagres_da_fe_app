import 'package:flutter/material.dart';

/// Item da programação exibido no carrossel da tela inicial.
///
/// Hoje os itens apontam para imagens locais ([assetPath]). Quando a
/// programação passar a vir do Firestore, basta preencher [imageUrl] — a
/// interface de exibição dá prioridade para a URL remota.
final class ProgramacaoItem {
  const ProgramacaoItem({
    required this.titulo,
    required this.data,
    this.assetPath,
    this.imageUrl,
  });

  /// Título sobreposto à imagem.
  final String titulo;

  /// Data/legenda curta sobreposta à imagem.
  final String data;

  /// Caminho de uma imagem local (assets).
  final String? assetPath;

  /// URL de uma imagem remota (Firestore/Storage) — usada quando disponível.
  final String? imageUrl;

  /// Resolve qual imagem deve ser exibida.
  ImageProvider? get imageProvider {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    if (assetPath != null && assetPath!.isNotEmpty) {
      return AssetImage(assetPath!);
    }
    return null;
  }
}

/// Programação exibida no carrossel enquanto a versão com Firestore não chega.
const programacaoAtual = <ProgramacaoItem>[
  ProgramacaoItem(
    titulo: 'Semana de Avivamento',
    data: '12 de junho • Cultos especiais',
    assetPath: 'assets/programacao/programacao_1.png',
  ),
  ProgramacaoItem(
    titulo: 'Grupo de Jovens',
    data: 'Toda quinta-feira • 19h30',
    assetPath: 'assets/programacao/programacao_2.png',
  ),
  ProgramacaoItem(
    titulo: 'Escola Bíblica Dominical',
    data: 'Domingos • 09h00',
    assetPath: 'assets/programacao/programacao_3.png',
  ),
];
