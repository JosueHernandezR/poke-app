import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonById implements UseCase<Pokemon, GetPokemonByIdParams> {
  final PokemonRepository repository;

  GetPokemonById(this.repository);

  @override
  Future<Either<Failure, Pokemon>> call(GetPokemonByIdParams params) {
    return repository.getPokemonById(params.id);
  }
}

class GetPokemonByIdParams extends Equatable {
  final int id;

  const GetPokemonByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}
