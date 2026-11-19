/// Modelo de uma receita da API DummyJSON.
///
/// Todos os campos opcionais são tratados com cuidado: a API pode omitir
/// valores ou trazer tipos diferentes do esperado (ex.: rating como int).
class Receita {
  const Receita({
    required this.id,
    required this.nome,
    required this.ingredientes,
    required this.instrucoes,
    required this.tiposRefeicao,
    this.imagem,
    this.preparoMin,
    this.cozimentoMin,
    this.porcoes,
    this.avaliacao,
    this.dificuldade,
    this.culinaria,
  });

  final int id;
  final String nome;
  final List<String> ingredientes;
  final List<String> instrucoes;
  final List<String> tiposRefeicao; // mealType é uma lista, não uma String
  final String? imagem;
  final int? preparoMin;
  final int? cozimentoMin;
  final int? porcoes;
  final num? avaliacao; // num: pode vir como int ou double
  final String? dificuldade;
  final String? culinaria;

  /// Tempo total só existe quando os DOIS tempos foram informados.
  /// Se faltar algum, devolve null (ausência != zero).
  int? get tempoTotalMin {
    if (preparoMin == null || cozimentoMin == null) return null;
    return preparoMin! + cozimentoMin!;
  }

  factory Receita.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! num) {
      throw const FormatException('Receita sem id válido');
    }

    final nome = json['name'];

    return Receita(
      id: id.toInt(),
      nome: (nome is String && nome.trim().isNotEmpty)
          ? nome.trim()
          : 'Receita sem nome',
      ingredientes: _comoListaDeTexto(json['ingredients']),
      instrucoes: _comoListaDeTexto(json['instructions']),
      tiposRefeicao: _comoListaDeTexto(json['mealType']),
      imagem: _comoTextoOuNulo(json['image']),
      preparoMin: _comoInteiroOuNulo(json['prepTimeMinutes']),
      cozimentoMin: _comoInteiroOuNulo(json['cookTimeMinutes']),
      porcoes: _comoInteiroOuNulo(json['servings']),
      avaliacao: json['rating'] is num ? json['rating'] as num : null,
      dificuldade: _comoTextoOuNulo(json['difficulty']),
      culinaria: _comoTextoOuNulo(json['cuisine']),
    );
  }

  // Receitas são iguais quando têm o mesmo id (evita duplicatas nos favoritos).
  @override
  bool operator ==(Object other) => other is Receita && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

List<String> _comoListaDeTexto(dynamic valor) {
  if (valor is! List) return const [];
  return valor.map((e) => e.toString()).toList();
}

String? _comoTextoOuNulo(dynamic valor) {
  if (valor is String && valor.trim().isNotEmpty) return valor.trim();
  return null;
}

int? _comoInteiroOuNulo(dynamic valor) {
  if (valor is num) return valor.toInt();
  return null;
}