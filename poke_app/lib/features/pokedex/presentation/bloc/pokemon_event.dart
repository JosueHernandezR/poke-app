part of 'pokemon_bloc.dart';

abstract class PokemonEvent extends Equatable {
  const PokemonEvent();

  @override
  List<Object> get props => [];
}

class LoadPokemonListEvent extends PokemonEvent {
  final int offset;
  final int limit;

  const LoadPokemonListEvent({this.offset = 0, this.limit = 20});

  @override
  List<Object> get props => [offset, limit];
}

class LoadMorePokemonEvent extends PokemonEvent {
  const LoadMorePokemonEvent();
}

class LoadPokemonByIdEvent extends PokemonEvent {
  final int id;

  const LoadPokemonByIdEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class SearchPokemonEvent extends PokemonEvent {
  final String query;

  const SearchPokemonEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class RefreshPokemonListEvent extends PokemonEvent {
  const RefreshPokemonListEvent();
}

class ClearSearchEvent extends PokemonEvent {
  const ClearSearchEvent();
}
