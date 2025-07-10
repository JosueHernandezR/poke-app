import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonByType
    implements UseCase<List<Pokemon>, GetPokemonByTypeParams> {
  final PokemonRepository repository;

  GetPokemonByType(this.repository);

  @override
  Future<Either<Failure, List<Pokemon>>> call(GetPokemonByTypeParams params) {
    return repository.getPokemonByType(params.type);
  }
}

class GetPokemonByTypeParams extends Equatable {
  final String type;

  const GetPokemonByTypeParams({required this.type});

  @override
  List<Object> get props => [type];
}
