import 'package:flutter/foundation.dart';

import '../models/receita.dart';

/// Única fonte de verdade dos favoritos (RF05).
///
/// Todas as telas usam a MESMA instância (`favoritos`, no fim do arquivo) e
/// se atualizam sozinhas via ChangeNotifier. Os dados ficam só na memória,
/// durante a sessão. Usa o id como chave, então não há duplicatas.
class Favoritos extends ChangeNotifier {
  final Map<int, Receita> _itens = {};

  List<Receita> get itens => List.unmodifiable(_itens.values);

  bool get vazio => _itens.isEmpty;

  bool contem(int id) => _itens.containsKey(id);

  /// Adiciona se não estiver na lista; remove se já estiver.
  void alternar(Receita receita) {
    if (_itens.containsKey(receita.id)) {
      _itens.remove(receita.id);
    } else {
      _itens[receita.id] = receita;
    }
    notifyListeners();
  }
}

final favoritos = Favoritos();