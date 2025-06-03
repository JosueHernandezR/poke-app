import 'package:equatable/equatable.dart';

class PokemonEvolution extends Equatable {
  final int id;
  final String name;
  final int? minLevel;
  final String? evolutionMethod;
  final String? item;
  final String imageUrl;

  const PokemonEvolution({
    required this.id,
    required this.name,
    this.minLevel,
    this.evolutionMethod,
    this.item,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    minLevel,
    evolutionMethod,
    item,
    imageUrl,
  ];
}

class EvolutionChain extends Equatable {
  final List<PokemonEvolution> evolutions;

  const EvolutionChain({required this.evolutions});

  @override
  List<Object?> get props => [evolutions];
}
