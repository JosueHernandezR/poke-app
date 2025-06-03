import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/usecases/get_pokemon_list.dart';
import '../../domain/usecases/get_pokemon_by_id.dart';
import '../../domain/usecases/search_pokemon.dart';

part 'pokemon_event.dart';
part 'pokemon_state.dart';

class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final GetPokemonList getPokemonList;
  final GetPokemonById getPokemonById;
  final SearchPokemon searchPokemon;

  // Variables para mantener el estado de la lista principal
  final List<Pokemon> _pokemonList = [];
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  PokemonBloc({
    required this.getPokemonList,
    required this.getPokemonById,
    required this.searchPokemon,
  }) : super(PokemonInitial()) {
    on<LoadPokemonListEvent>(_onLoadPokemonList);
    on<LoadMorePokemonEvent>(_onLoadMorePokemon);
    on<LoadPokemonByIdEvent>(_onLoadPokemonById);
    on<SearchPokemonEvent>(_onSearchPokemon);
    on<RefreshPokemonListEvent>(_onRefreshPokemonList);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onLoadPokemonList(
    LoadPokemonListEvent event,
    Emitter<PokemonState> emit,
  ) async {
    if (_pokemonList.isEmpty) {
      emit(PokemonLoading());
    }

    final result = await getPokemonList(
      GetPokemonListParams(offset: event.offset, limit: event.limit),
    );

    result.fold((failure) => emit(PokemonError(message: failure.message)), (
      pokemonList,
    ) {
      _pokemonList.clear();
      _pokemonList.addAll(pokemonList);
      _currentOffset = event.offset + event.limit;
      _hasMore = pokemonList.length == event.limit;

      emit(
        PokemonListLoaded(
          pokemonList: List.from(_pokemonList),
          hasMore: _hasMore,
        ),
      );
    });
  }

  Future<void> _onLoadMorePokemon(
    LoadMorePokemonEvent event,
    Emitter<PokemonState> emit,
  ) async {
    if (!_hasMore) return;

    final currentState = state;
    if (currentState is PokemonListLoaded && !currentState.isLoadingMore) {
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await getPokemonList(
        GetPokemonListParams(offset: _currentOffset, limit: _limit),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingMore: false)),
        (newPokemon) {
          _pokemonList.addAll(newPokemon);
          _currentOffset += _limit;
          _hasMore = newPokemon.length == _limit;

          emit(
            PokemonListLoaded(
              pokemonList: List.from(_pokemonList),
              hasMore: _hasMore,
              isLoadingMore: false,
            ),
          );
        },
      );
    }
  }

  Future<void> _onLoadPokemonById(
    LoadPokemonByIdEvent event,
    Emitter<PokemonState> emit,
  ) async {
    emit(PokemonLoading());

    final result = await getPokemonById(GetPokemonByIdParams(id: event.id));

    result.fold(
      (failure) => emit(PokemonError(message: failure.message)),
      (pokemon) => emit(PokemonDetailLoaded(pokemon: pokemon)),
    );
  }

  Future<void> _onSearchPokemon(
    SearchPokemonEvent event,
    Emitter<PokemonState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const PokemonSearchLoaded(searchResults: [], query: ''));
      return;
    }

    emit(PokemonLoading());

    final result = await searchPokemon(SearchPokemonParams(query: event.query));

    result.fold(
      (failure) => emit(PokemonError(message: failure.message)),
      (searchResults) => emit(
        PokemonSearchLoaded(searchResults: searchResults, query: event.query),
      ),
    );
  }

  Future<void> _onRefreshPokemonList(
    RefreshPokemonListEvent event,
    Emitter<PokemonState> emit,
  ) async {
    _pokemonList.clear();
    _currentOffset = 0;
    _hasMore = true;

    final result = await getPokemonList(
      GetPokemonListParams(offset: 0, limit: _limit),
    );

    result.fold((failure) => emit(PokemonError(message: failure.message)), (
      pokemonList,
    ) {
      _pokemonList.addAll(pokemonList);
      _currentOffset = _limit;
      _hasMore = pokemonList.length == _limit;

      emit(
        PokemonListLoaded(
          pokemonList: List.from(_pokemonList),
          hasMore: _hasMore,
        ),
      );
    });
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<PokemonState> emit,
  ) async {
    // Restaurar el estado de la lista principal
    if (_pokemonList.isNotEmpty) {
      emit(
        PokemonListLoaded(
          pokemonList: List.from(_pokemonList),
          hasMore: _hasMore,
        ),
      );
    } else {
      emit(PokemonInitial());
    }
  }
}
