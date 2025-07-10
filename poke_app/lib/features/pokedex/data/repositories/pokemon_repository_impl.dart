import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_evolution.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_local_datasource.dart';
import '../datasources/pokemon_remote_datasource.dart';
import '../models/pokemon_model.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;
  final PokemonLocalDataSource localDataSource;

  PokemonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Pokemon>>> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      // Si el offset es 0, intentar obtener de caché primero
      if (offset == 0) {
        final cachedPokemon = await localDataSource.getCachedPokemonList();
        if (cachedPokemon.isNotEmpty && cachedPokemon.length >= limit) {
          return Right(
            cachedPokemon.take(limit).map((model) => model.toEntity()).toList(),
          );
        }
      }

      // Obtener de la API
      final response = await remoteDataSource.getPokemonList(offset, limit);
      final results = response['results'] as List;

      final pokemonList = <PokemonModel>[];

      // Obtener detalles de cada Pokémon
      for (final result in results) {
        final pokemonResponse = await remoteDataSource.getPokemonByName(
          result['name'],
        );
        final pokemon = PokemonModel.fromPokeApiJson(pokemonResponse);
        pokemonList.add(pokemon);
      }

      // Si es la primera carga (offset 0), reemplazar caché
      // Si es carga adicional, agregar al caché existente SOLO si no existen
      if (offset == 0) {
        await localDataSource.cachePokemonList(pokemonList);
      } else {
        // Para cargas adicionales, verificar duplicados antes de agregar
        final existingCache = await localDataSource.getCachedPokemonList();
        final existingIds = existingCache.map((p) => p.id).toSet();

        // Solo agregar pokémon que no existen en el caché
        final newPokemon =
            pokemonList.where((p) => !existingIds.contains(p.id)).toList();

        if (newPokemon.isNotEmpty) {
          final updatedCache = [...existingCache, ...newPokemon];
          await localDataSource.cachePokemonList(updatedCache);
        }
      }

      return Right(pokemonList.map((model) => model.toEntity()).toList());
    } on ServerException {
      return const Left(ServerFailure(message: 'Error del servidor'));
    } on CacheException {
      return const Left(CacheFailure(message: 'Error de caché'));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error desconocido: $e'));
    }
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) async {
    try {
      // Intentar obtener de caché primero
      final cachedPokemon = await localDataSource.getCachedPokemon(id);
      if (cachedPokemon != null) {
        return Right(cachedPokemon.toEntity());
      }

      // Si no está en caché, obtener de la API
      final response = await remoteDataSource.getPokemonById(id);
      final pokemon = PokemonModel.fromPokeApiJson(response);

      // Guardar en caché
      await localDataSource.cachePokemon(pokemon);

      return Right(pokemon.toEntity());
    } on ServerException {
      return const Left(ServerFailure(message: 'Error del servidor'));
    } on NotFoundException {
      return const Left(NotFoundFailure(message: 'Pokémon no encontrado'));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error desconocido: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Pokemon>>> searchPokemon(String query) async {
    try {
      // Primero intentar buscar en caché
      final cachedPokemon = await localDataSource.getCachedPokemonList();

      var filteredPokemon =
          cachedPokemon
              .where(
                (pokemon) =>
                    pokemon.name.toLowerCase().contains(query.toLowerCase()) ||
                    pokemon.id.toString() == query,
              )
              .toList();

      // Si encontramos resultados en caché, devolverlos inmediatamente
      if (filteredPokemon.isNotEmpty) {
        return Right(filteredPokemon.map((model) => model.toEntity()).toList());
      }

      // Si no hay resultados en caché, intentar buscar directamente en la API
      try {
        // Intentar buscar por nombre exacto primero
        final response = await remoteDataSource.getPokemonByName(
          query.toLowerCase(),
        );
        final pokemon = PokemonModel.fromPokeApiJson(response);

        // Guardar en caché individual para futuras búsquedas
        await localDataSource.cachePokemon(pokemon);

        // También agregarlo a la lista principal cacheada si no existe
        final existingCachedList = await localDataSource.getCachedPokemonList();
        final existsInMainCache = existingCachedList.any(
          (p) => p.id == pokemon.id,
        );

        if (!existsInMainCache) {
          final updatedCache = [...existingCachedList, pokemon];
          await localDataSource.cachePokemonList(updatedCache);
        }

        return Right([pokemon.toEntity()]);
      } catch (e) {
        // Si no se encuentra por nombre exacto, intentar buscar por ID
        try {
          final id = int.tryParse(query);
          if (id != null) {
            final response = await remoteDataSource.getPokemonById(id);
            final pokemon = PokemonModel.fromPokeApiJson(response);

            // Guardar en caché individual para futuras búsquedas
            await localDataSource.cachePokemon(pokemon);

            // También agregarlo a la lista principal cacheada si no existe
            final existingCachedList =
                await localDataSource.getCachedPokemonList();
            final existsInMainCache = existingCachedList.any(
              (p) => p.id == pokemon.id,
            );

            if (!existsInMainCache) {
              final updatedCache = [...existingCachedList, pokemon];
              await localDataSource.cachePokemonList(updatedCache);
            }

            return Right([pokemon.toEntity()]);
          }
        } catch (e) {
          // Si tampoco funciona por ID, devolver lista vacía
        }
      }

      // Si no se encuentra nada, devolver lista vacía
      return const Right([]);
    } catch (e) {
      return Left(UnknownFailure(message: 'Error en búsqueda: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Pokemon>>> getPokemonByType(String type) async {
    try {
      final response = await remoteDataSource.getPokemonByType(type);
      final pokemon = response['pokemon'] as List;

      final pokemonList = <PokemonModel>[];

      for (final item in pokemon) {
        final pokemonData = item['pokemon'];
        final pokemonResponse = await remoteDataSource.getPokemonByName(
          pokemonData['name'],
        );
        final pokemonModel = PokemonModel.fromPokeApiJson(pokemonResponse);
        pokemonList.add(pokemonModel);
      }

      return Right(pokemonList.map((model) => model.toEntity()).toList());
    } on ServerException {
      return const Left(ServerFailure(message: 'Error del servidor'));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error desconocido: $e'));
    }
  }

  @override
  Future<Either<Failure, EvolutionChain>> getEvolutionChain(
    int pokemonId,
  ) async {
    // TODO: Implementar cuando se agregue el modelo de evolución
    return const Left(UnknownFailure(message: 'No implementado aún'));
  }

  @override
  Future<Either<Failure, List<Pokemon>>> getFavoritePokemon() async {
    try {
      final favorites = await localDataSource.getFavoritePokemon();
      return Right(favorites.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: 'Error al obtener favoritos: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addToFavorites(Pokemon pokemon) async {
    try {
      final model = PokemonModel(
        id: pokemon.id,
        name: pokemon.name,
        types: pokemon.types,
        height: pokemon.height,
        weight: pokemon.weight,
        stats: pokemon.stats,
        abilities: pokemon.abilities,
        imageUrl: pokemon.imageUrl,
        description: pokemon.description,
        isShiny: pokemon.isShiny,
      );

      await localDataSource.addToFavorites(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al agregar a favoritos: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFromFavorites(int pokemonId) async {
    try {
      await localDataSource.removeFromFavorites(pokemonId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al quitar de favoritos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int pokemonId) async {
    try {
      final result = await localDataSource.isFavorite(pokemonId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al verificar favorito: $e'));
    }
  }

  // Método para limpiar el caché (útil para debugging)
  Future<void> clearCache() async {
    await localDataSource.clearAllCache();
  }
}
