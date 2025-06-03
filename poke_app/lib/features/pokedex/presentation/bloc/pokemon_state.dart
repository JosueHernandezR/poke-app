part of 'pokemon_bloc.dart';

abstract class PokemonState extends Equatable {
  const PokemonState();

  @override
  List<Object> get props => [];
}

class PokemonInitial extends PokemonState {}

class PokemonLoading extends PokemonState {}

class PokemonListLoaded extends PokemonState {
  final List<Pokemon> pokemonList;
  final bool hasMore;
  final bool isLoadingMore;

  const PokemonListLoaded({
    required this.pokemonList,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PokemonListLoaded copyWith({
    List<Pokemon>? pokemonList,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PokemonListLoaded(
      pokemonList: pokemonList ?? this.pokemonList,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [pokemonList, hasMore, isLoadingMore];
}

class PokemonSearchLoaded extends PokemonState {
  final List<Pokemon> searchResults;
  final String query;

  const PokemonSearchLoaded({required this.searchResults, required this.query});

  @override
  List<Object> get props => [searchResults, query];
}

class PokemonDetailLoaded extends PokemonState {
  final Pokemon pokemon;

  const PokemonDetailLoaded({required this.pokemon});

  @override
  List<Object> get props => [pokemon];
}

class PokemonError extends PokemonState {
  final String message;

  const PokemonError({required this.message});

  @override
  List<Object> get props => [message];
}
