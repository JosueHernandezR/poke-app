import 'package:hive_flutter/hive_flutter.dart';
import '../models/pokemon_model.dart';

abstract class PokemonLocalDataSource {
  Future<List<PokemonModel>> getCachedPokemonList();
  Future<PokemonModel?> getCachedPokemon(int id);
  Future<void> cachePokemonList(List<PokemonModel> pokemonList);
  Future<void> cachePokemon(PokemonModel pokemon);
  Future<List<PokemonModel>> getFavoritePokemon();
  Future<void> addToFavorites(PokemonModel pokemon);
  Future<void> removeFromFavorites(int pokemonId);
  Future<bool> isFavorite(int pokemonId);
  Future<void> clearAllCache();
}

class PokemonLocalDataSourceImpl implements PokemonLocalDataSource {
  static const String pokemonBoxName = 'pokemon_cache';
  static const String favoritesBoxName = 'favorites';

  @override
  Future<List<PokemonModel>> getCachedPokemonList() async {
    final box = await Hive.openBox(pokemonBoxName);
    final cachedList = box.get('pokemon_list') as List?;

    if (cachedList == null) {
      print('💾 CACHE DEBUG: No hay lista cacheada');
      return [];
    }

    final pokemonModels =
        cachedList
            .map(
              (json) => PokemonModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

    print(
      '💾 CACHE DEBUG: Lista cacheada tiene ${pokemonModels.length} pokémon',
    );

    // ELIMINAR DUPLICADOS AUTOMÁTICAMENTE
    final seenIds = <int>{};
    final uniquePokemon = <PokemonModel>[];
    final duplicates = <PokemonModel>[];

    for (var pokemon in pokemonModels) {
      if (seenIds.contains(pokemon.id)) {
        duplicates.add(pokemon);
        print(
          '💾 CACHE DEBUG: ¡DUPLICADO ELIMINADO! ${pokemon.name} (ID: ${pokemon.id})',
        );
      } else {
        seenIds.add(pokemon.id);
        uniquePokemon.add(pokemon);
      }
    }

    // Si había duplicados, actualizar el caché con la lista limpia
    if (duplicates.isNotEmpty) {
      print(
        '💾 CACHE DEBUG: ¡Se eliminaron ${duplicates.length} duplicados! Actualizando caché...',
      );
      await cachePokemonList(uniquePokemon);
    }

    return uniquePokemon;
  }

  @override
  Future<PokemonModel?> getCachedPokemon(int id) async {
    final box = await Hive.openBox(pokemonBoxName);
    final cached = box.get('pokemon_$id');

    if (cached == null) return null;

    return PokemonModel.fromJson(Map<String, dynamic>.from(cached));
  }

  @override
  Future<void> cachePokemonList(List<PokemonModel> pokemonList) async {
    final box = await Hive.openBox(pokemonBoxName);

    print('💾 CACHE DEBUG: Guardando ${pokemonList.length} pokémon en caché');

    // ELIMINAR DUPLICADOS ANTES DE GUARDAR
    final seenIds = <int>{};
    final uniquePokemon = <PokemonModel>[];

    for (var pokemon in pokemonList) {
      if (!seenIds.contains(pokemon.id)) {
        seenIds.add(pokemon.id);
        uniquePokemon.add(pokemon);
      } else {
        print(
          '💾 CACHE DEBUG: Duplicado evitado al guardar: ${pokemon.name} (ID: ${pokemon.id})',
        );
      }
    }

    final jsonList = uniquePokemon.map((pokemon) => pokemon.toJson()).toList();
    await box.put('pokemon_list', jsonList);
    print(
      '💾 CACHE DEBUG: ${uniquePokemon.length} pokémon únicos guardados en caché',
    );
  }

  @override
  Future<void> cachePokemon(PokemonModel pokemon) async {
    final box = await Hive.openBox(pokemonBoxName);
    await box.put('pokemon_${pokemon.id}', pokemon.toJson());
    print(
      '💾 CACHE DEBUG: Pokémon individual guardado: ${pokemon.name} (ID: ${pokemon.id})',
    );
  }

  @override
  Future<void> clearAllCache() async {
    final pokemonBox = await Hive.openBox(pokemonBoxName);
    await pokemonBox.clear();
    print('💾 CACHE DEBUG: ¡Caché completamente limpiado!');
  }

  @override
  Future<List<PokemonModel>> getFavoritePokemon() async {
    final box = await Hive.openBox(favoritesBoxName);
    final favorites = <PokemonModel>[];

    for (final key in box.keys) {
      final json = box.get(key);
      if (json != null) {
        favorites.add(PokemonModel.fromJson(Map<String, dynamic>.from(json)));
      }
    }

    return favorites;
  }

  @override
  Future<void> addToFavorites(PokemonModel pokemon) async {
    final box = await Hive.openBox(favoritesBoxName);
    await box.put('pokemon_${pokemon.id}', pokemon.toJson());
  }

  @override
  Future<void> removeFromFavorites(int pokemonId) async {
    final box = await Hive.openBox(favoritesBoxName);
    await box.delete('pokemon_$pokemonId');
  }

  @override
  Future<bool> isFavorite(int pokemonId) async {
    final box = await Hive.openBox(favoritesBoxName);
    return box.containsKey('pokemon_$pokemonId');
  }
}
