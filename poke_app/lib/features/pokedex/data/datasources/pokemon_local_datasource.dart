import 'package:hive/hive.dart';
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
}

class PokemonLocalDataSourceImpl implements PokemonLocalDataSource {
  static const String pokemonBoxName = 'pokemon_cache';
  static const String favoritesBoxName = 'favorites';

  @override
  Future<List<PokemonModel>> getCachedPokemonList() async {
    final box = await Hive.openBox(pokemonBoxName);
    final cachedList = box.get('pokemon_list') as List?;

    if (cachedList == null) return [];

    return cachedList
        .map((json) => PokemonModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
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
    final jsonList = pokemonList.map((pokemon) => pokemon.toJson()).toList();
    await box.put('pokemon_list', jsonList);
  }

  @override
  Future<void> cachePokemon(PokemonModel pokemon) async {
    final box = await Hive.openBox(pokemonBoxName);
    await box.put('pokemon_${pokemon.id}', pokemon.toJson());
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
