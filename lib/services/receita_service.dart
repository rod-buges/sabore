import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/receita.dart';

enum TipoErro { rede, servidor, formato }

/// Erro com mensagem já pronta para mostrar ao usuário (RF07).
class ReceitaException implements Exception {
  const ReceitaException(this.tipo, this.mensagem);

  final TipoErro tipo;
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Acesso à API DummyJSON Recipes.
///
/// Decisão de detalhe (RF04): o objeto retornado pela listagem já contém
/// ingredientes, instruções, tempos etc., então a tela de detalhes reaproveita
/// o objeto `Receita` recebido, sem chamar /recipes/{id}.
class ReceitaService {
  static const _host = 'dummyjson.com';

  /// Lista as receitas (a API tem 50 no total).
  Future<List<Receita>> listar() {
    return _buscar(Uri.https(_host, '/recipes', {'limit': '50'}));
  }

  /// Pesquisa por nome no endpoint remoto. Recusa consulta vazia.
  Future<List<Receita>> pesquisar(String termo) {
    final consulta = termo.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (consulta.isEmpty) {
      throw ArgumentError('A consulta não pode ser vazia');
    }
    return _buscar(Uri.https(_host, '/recipes/search', {'q': consulta}));
  }

  Future<List<Receita>> _buscar(Uri uri) async {
    try {
      final resposta =
      await http.get(uri).timeout(const Duration(seconds: 15));

      if (resposta.statusCode != 200) {
        throw const ReceitaException(
          TipoErro.servidor,
          'O servidor respondeu com erro. Tente novamente em instantes.',
        );
      }

      final corpo = jsonDecode(resposta.body);
      if (corpo is! Map<String, dynamic> || corpo['recipes'] is! List) {
        throw const ReceitaException(
          TipoErro.formato,
          'Recebemos dados em um formato inesperado.',
        );
      }

      return (corpo['recipes'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Receita.fromJson)
          .toList();
    } on ReceitaException {
      rethrow;
    } on TimeoutException {
      throw const ReceitaException(
        TipoErro.rede,
        'A conexão demorou demais. Verifique sua internet e tente novamente.',
      );
    } on http.ClientException {
      throw const ReceitaException(
        TipoErro.rede,
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
      );
    } on FormatException {
      throw const ReceitaException(
        TipoErro.formato,
        'Recebemos dados em um formato inesperado.',
      );
    }
  }
}