import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/pokedex/data/datasources/pokemon_remote_datasource.dart';
import '../../features/pokedex/data/datasources/pokemon_local_datasource.dart';
import '../../features/pokedex/data/repositories/pokemon_repository_impl.dart';
import '../../features/pokedex/domain/repositories/pokemon_repository.dart';
import '../../features/pokedex/domain/usecases/get_pokemon_list.dart';
import '../../features/pokedex/domain/usecases/get_pokemon_by_id.dart';
import '../../features/pokedex/domain/usecases/search_pokemon.dart';
import '../../features/pokedex/domain/usecases/get_pokemon_by_type.dart';
import '../../features/pokedex/presentation/bloc/pokemon_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Inicializar Hive
  await Hive.initFlutter();

  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Dio
  sl.registerLazySingleton(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    return dio;
  });

  // Data sources
  sl.registerLazySingleton<PokemonRemoteDataSource>(
    () => PokemonRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<PokemonLocalDataSource>(
    () => PokemonLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPokemonList(sl()));
  sl.registerLazySingleton(() => GetPokemonById(sl()));
  sl.registerLazySingleton(() => SearchPokemon(sl()));
  sl.registerLazySingleton(() => GetPokemonByType(sl()));

  // BLoC - Cada página tendrá su propia instancia
  sl.registerFactory(
    () => PokemonBloc(
      getPokemonList: sl(),
      getPokemonById: sl(),
      searchPokemon: sl(),
      getPokemonByType: sl(),
    ),
  );
}
