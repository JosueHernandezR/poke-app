import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonList implements UseCase<List<Pokemon>, GetPokemonListParams> {
  final PokemonRepository repository;

  GetPokemonList(this.repository);

  @override
  Future<Either<Failure, List<Pokemon>>> call(GetPokemonListParams params) {
    return repository.getPokemonList(
      offset: params.offset,
      limit: params.limit,
    );
  }
}

class GetPokemonListParams extends Equatable {
  final int offset;
  final int limit;

  const GetPokemonListParams({required this.offset, required this.limit});

  @override
  List<Object> get props => [offset, limit];
}
