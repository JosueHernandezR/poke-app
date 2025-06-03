class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://pokeapi.co/api/v2/';
  static const String imageBaseUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/';

  // Endpoints
  static const String pokemon = 'pokemon';
  static const String pokemonSpecies = 'pokemon-species';
  static const String evolutionChain = 'evolution-chain';
  static const String type = 'type';
  static const String ability = 'ability';
  static const String move = 'move';
  static const String generation = 'generation';
  static const String region = 'region';
  static const String location = 'location';

  // Pagination
  static const int defaultLimit = 20;
  static const int maxLimit = 100;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheMaxAge = Duration(hours: 24);
  static const Duration cacheMaxStale = Duration(days: 7);

  // Image URLs
  static String getPokemonImageUrl(int id) {
    return '$imageBaseUrl$id.png';
  }

  static String getPokemonSpriteUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }

  static String getPokemonShinyImageUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';
  }

  static String getPokemonAnimatedSpriteUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif';
  }

  // Generation ranges
  static const Map<String, Map<String, int>> generationRanges = {
    'generation-i': {'start': 1, 'end': 151},
    'generation-ii': {'start': 152, 'end': 251},
    'generation-iii': {'start': 252, 'end': 386},
    'generation-iv': {'start': 387, 'end': 493},
    'generation-v': {'start': 494, 'end': 649},
    'generation-vi': {'start': 650, 'end': 721},
    'generation-vii': {'start': 722, 'end': 809},
    'generation-viii': {'start': 810, 'end': 905},
    'generation-ix': {'start': 906, 'end': 1010},
  };

  // Type effectiveness multipliers
  static const Map<String, double> typeEffectiveness = {
    'super_effective': 2.0,
    'not_very_effective': 0.5,
    'no_effect': 0.0,
    'normal': 1.0,
  };

  // Status codes
  static const int statusOk = 200;
  static const int statusNotFound = 404;
  static const int statusServerError = 500;

  // Error messages
  static const String networkError = 'Error de conexión. Verifica tu internet.';
  static const String serverError = 'Error del servidor. Intenta más tarde.';
  static const String notFoundError = 'Pokémon no encontrado.';
  static const String unknownError = 'Error desconocido. Intenta más tarde.';
  static const String cacheError = 'Error al cargar datos guardados.';
}
