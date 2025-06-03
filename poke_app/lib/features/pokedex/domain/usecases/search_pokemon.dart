import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class SearchPokemon implements UseCase<List<Pokemon>, SearchPokemonParams> {
  final PokemonRepository repository;

  SearchPokemon(this.repository);

  @override
  Future<Either<Failure, List<Pokemon>>> call(SearchPokemonParams params) {
    return repository.searchPokemon(params.query);
  }
}

class SearchPokemonParams extends Equatable {
  final String query;

  const SearchPokemonParams({required this.query});

  @override
  List<Object> get props => [query];
}
