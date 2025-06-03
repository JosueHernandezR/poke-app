import '../../domain/entities/pokemon.dart';

class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.types,
    required super.height,
    required super.weight,
    required super.stats,
    required super.abilities,
    required super.imageUrl,
    super.description,
    super.isShiny,
  });

  // Conversión manual desde JSON
  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      stats: Map<String, int>.from(json['stats'] ?? {}),
      abilities: List<String>.from(json['abilities'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'],
      isShiny: json['isShiny'] ?? false,
    );
  }

  // Conversión manual a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types,
      'height': height,
      'weight': weight,
      'stats': stats,
      'abilities': abilities,
      'imageUrl': imageUrl,
      'description': description,
      'isShiny': isShiny,
    };
  }

  // Factory para crear desde respuesta de PokeAPI
  factory PokemonModel.fromPokeApiJson(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'],
      name: json['name'],
      types:
          (json['types'] as List)
              .map((type) => type['type']['name'] as String)
              .toList(),
      height: json['height'],
      weight: json['weight'],
      stats: Map.fromEntries(
        (json['stats'] as List).map(
          (stat) => MapEntry(
            stat['stat']['name'] as String,
            stat['base_stat'] as int,
          ),
        ),
      ),
      abilities:
          (json['abilities'] as List)
              .map((ability) => ability['ability']['name'] as String)
              .toList(),
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'] ??
          '',
    );
  }

  Pokemon toEntity() => Pokemon(
    id: id,
    name: name,
    types: types,
    height: height,
    weight: weight,
    stats: stats,
    abilities: abilities,
    imageUrl: imageUrl,
    description: description,
    isShiny: isShiny,
  );
}
