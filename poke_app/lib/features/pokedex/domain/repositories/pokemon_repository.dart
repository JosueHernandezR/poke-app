import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pokemon.dart';
import '../entities/pokemon_evolution.dart';

abstract class PokemonRepository {
  Future<Either<Failure, List<Pokemon>>> getPokemonList({
    int offset = 0,
    int limit = 20,
  });

  Future<Either<Failure, Pokemon>> getPokemonById(int id);

  Future<Either<Failure, List<Pokemon>>> searchPokemon(String query);

  Future<Either<Failure, List<Pokemon>>> getPokemonByType(String type);

  Future<Either<Failure, EvolutionChain>> getEvolutionChain(int pokemonId);

  Future<Either<Failure, List<Pokemon>>> getFavoritePokemon();

  Future<Either<Failure, Unit>> addToFavorites(Pokemon pokemon);

  Future<Either<Failure, Unit>> removeFromFavorites(int pokemonId);

  Future<Either<Failure, bool>> isFavorite(int pokemonId);
}
