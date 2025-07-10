import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../domain/entities/pokemon.dart';
import '../../domain/usecases/get_pokemon_list.dart';
import '../../domain/usecases/get_pokemon_by_id.dart';
import '../../domain/usecases/search_pokemon.dart';
import '../../domain/usecases/get_pokemon_by_type.dart';

part 'pokemon_event.dart';
part 'pokemon_state.dart';

class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final GetPokemonList getPokemonList;
  final GetPokemonById getPokemonById;
  final SearchPokemon searchPokemon;
  final GetPokemonByType getPokemonByType;

  // Variables para mantener el estado de la lista principal
  final List<Pokemon> _pokemonList = [];
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  // Variables para búsqueda y filtros
  Timer? _debounceTimer;
  String _currentSearchQuery = '';
  List<String> _currentSelectedTypes = [];

  PokemonBloc({
    required this.getPokemonList,
    required this.getPokemonById,
    required this.searchPokemon,
    required this.getPokemonByType,
  }) : super(PokemonInitial()) {
    on<LoadPokemonListEvent>(_onLoadPokemonList);
    on<LoadMorePokemonEvent>(_onLoadMorePokemon);
    on<LoadPokemonByIdEvent>(_onLoadPokemonById);
    on<SearchPokemonEvent>(_onSearchPokemon);
    on<LocalSearchEvent>(_onLocalSearch);
    on<FilterByTypesEvent>(_onFilterByTypes);
    on<RefreshPokemonListEvent>(_onRefreshPokemonList);
    on<ClearSearchEvent>(_onClearSearch);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
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

  Future<void> _onLocalSearch(
    LocalSearchEvent event,
    Emitter<PokemonState> emit,
  ) async {
    print(
      '📱 BLOC DEBUG: LocalSearchEvent recibido - query: "${event.query}", tipos: ${event.selectedTypes}',
    );
    print('📱 BLOC DEBUG: Pokemon list tiene ${_pokemonList.length} elementos');

    _currentSearchQuery = event.query;
    _currentSelectedTypes = event.selectedTypes;

    // Cancelar cualquier timer anterior
    _debounceTimer?.cancel();

    // Si no hay datos cargados aún, esperar a que se carguen
    if (_pokemonList.isEmpty) {
      print('📱 BLOC DEBUG: Lista vacía, emitiendo PokemonLoading');
      emit(PokemonLoading());
      return;
    }

    // Si la consulta está vacía y no hay filtros, mostrar todos los Pokémon
    if (event.query.isEmpty && event.selectedTypes.isEmpty) {
      print('📱 BLOC DEBUG: Query vacío, mostrando todos los Pokémon');
      emit(
        PokemonListLoaded(
          pokemonList: List.from(_pokemonList),
          hasMore: _hasMore,
        ),
      );
      return;
    }

    // Aplicar búsqueda inmediatamente para que sea realmente "en tiempo real"
    print('📱 BLOC DEBUG: Aplicando búsqueda local');
    _performLocalSearch(event.query, event.selectedTypes, emit);
  }

  void _performLocalSearch(
    String query,
    List<String> selectedTypes,
    Emitter<PokemonState> emit,
  ) {
    print('🔎 PERFORM SEARCH: query="$query", tipos=$selectedTypes');

    // Verificar que tenemos datos para buscar
    if (_pokemonList.isEmpty) {
      print('🔎 PERFORM SEARCH: Lista vacía, emitiendo loading');
      emit(PokemonLoading());
      return;
    }

    List<Pokemon> filteredPokemon = List.from(_pokemonList);
    print('🔎 PERFORM SEARCH: Iniciando con ${filteredPokemon.length} Pokémon');

    // Filtrar por búsqueda de texto (nombre o ID)
    if (query.isNotEmpty) {
      final queryLower = query.toLowerCase().trim();
      filteredPokemon =
          filteredPokemon.where((pokemon) {
            // Buscar por nombre (coincidencias parciales)
            final nameMatch = pokemon.name.toLowerCase().contains(queryLower);

            // Buscar por ID (coincidencia exacta o que comience con)
            final idMatch =
                pokemon.id.toString().startsWith(query) ||
                pokemon.id.toString() == query;

            return nameMatch || idMatch;
          }).toList();

      print(
        '🔎 PERFORM SEARCH: Después del filtro de texto: ${filteredPokemon.length} Pokémon',
      );
    }

    // Filtrar por tipos seleccionados
    if (selectedTypes.isNotEmpty) {
      filteredPokemon =
          filteredPokemon.where((pokemon) {
            // El Pokémon debe tener al menos uno de los tipos seleccionados
            return pokemon.types.any((type) => selectedTypes.contains(type));
          }).toList();

      print(
        '🔎 PERFORM SEARCH: Después del filtro de tipos: ${filteredPokemon.length} Pokémon',
      );
    }

    // Ordenar resultados: primero los que comienzan con la búsqueda, luego los que la contienen
    if (query.isNotEmpty) {
      final queryLower = query.toLowerCase().trim();
      filteredPokemon.sort((a, b) {
        final aStartsWith = a.name.toLowerCase().startsWith(queryLower);
        final bStartsWith = b.name.toLowerCase().startsWith(queryLower);

        // Prioridad 1: Los que comienzan con la búsqueda
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        // Prioridad 2: Si ambos comienzan igual o no comienzan, ordenar por relevancia
        if (aStartsWith && bStartsWith) {
          // Si ambos comienzan con la búsqueda, ordenar por longitud de nombre (más corto primero)
          final lengthDiff = a.name.length.compareTo(b.name.length);
          if (lengthDiff != 0) return lengthDiff;
        }

        // Prioridad 3: Ordenar por ID
        return a.id.compareTo(b.id);
      });
    } else {
      // Si no hay búsqueda de texto, ordenar solo por ID
      filteredPokemon.sort((a, b) => a.id.compareTo(b.id));
    }

    print('🔎 PERFORM SEARCH: Emitiendo ${filteredPokemon.length} resultados');
    emit(PokemonSearchLoaded(searchResults: filteredPokemon, query: query));
  }

  Future<void> _onFilterByTypes(
    FilterByTypesEvent event,
    Emitter<PokemonState> emit,
  ) async {
    _currentSelectedTypes = event.types;

    // Aplicar los filtros actuales
    add(
      LocalSearchEvent(
        query: _currentSearchQuery,
        selectedTypes: _currentSelectedTypes,
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
