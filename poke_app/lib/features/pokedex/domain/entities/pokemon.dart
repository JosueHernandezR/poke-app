import 'package:equatable/equatable.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final List<String> types;
  final int height;
  final int weight;
  final Map<String, int> stats;
  final List<String> abilities;
  final String imageUrl;
  final String description;
  final bool isShiny;

  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
    required this.abilities,
    required this.imageUrl,
    this.description = '',
    this.isShiny = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    types,
    height,
    weight,
    stats,
    abilities,
    imageUrl,
    description,
    isShiny,
  ];

  Pokemon copyWith({
    int? id,
    String? name,
    List<String>? types,
    int? height,
    int? weight,
    Map<String, int>? stats,
    List<String>? abilities,
    String? imageUrl,
    String? description,
    bool? isShiny,
  }) {
    return Pokemon(
      id: id ?? this.id,
      name: name ?? this.name,
      types: types ?? this.types,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      stats: stats ?? this.stats,
      abilities: abilities ?? this.abilities,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isShiny: isShiny ?? this.isShiny,
    );
  }
}
