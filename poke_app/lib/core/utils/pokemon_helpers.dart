import 'dart:math';

class PokemonHelpers {
  // Formatear número de Pokédex
  static String formatPokedexNumber(int number) {
    return '#${number.toString().padLeft(3, '0')}';
  }

  // Formatear altura (de decímetros a metros)
  static String formatHeight(int heightInDecimeters) {
    final meters = heightInDecimeters / 10.0;
    return '${meters.toStringAsFixed(1)} m';
  }

  // Formatear peso (de hectogramos a kilogramos)
  static String formatWeight(int weightInHectograms) {
    final kilograms = weightInHectograms / 10.0;
    return '${kilograms.toStringAsFixed(1)} kg';
  }

  // Formatear estadística base
  static String formatBaseStat(int stat) {
    return stat.toString();
  }

  // Calcular total de estadísticas base
  static int calculateBaseStatTotal(Map<String, int> stats) {
    return stats.values.fold(0, (sum, stat) => sum + stat);
  }

  // Obtener rango de estadística
  static String getStatRange(int baseStat) {
    if (baseStat < 30) return 'Muy Bajo';
    if (baseStat < 60) return 'Bajo';
    if (baseStat < 90) return 'Medio';
    if (baseStat < 120) return 'Alto';
    if (baseStat < 150) return 'Muy Alto';
    return 'Extremo';
  }

  // Calcular porcentaje de estadística (máximo 255)
  static double getStatPercentage(int stat) {
    return (stat / 255.0).clamp(0.0, 1.0);
  }

  // Generar ID aleatorio para Pokémon
  static int getRandomPokemonId({int max = 1010}) {
    final random = Random();
    return random.nextInt(max) + 1;
  }

  // Verificar si es Pokémon shiny (1/4096 probabilidad)
  static bool isShinyPokemon() {
    final random = Random();
    return random.nextInt(4096) == 0;
  }

  // Capitalizar primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Formatear nombre de Pokémon
  static String formatPokemonName(String name) {
    return name.split('-').map((part) => capitalize(part)).join(' ');
  }

  // Obtener generación por ID
  static int getGenerationByPokemonId(int id) {
    if (id <= 151) return 1;
    if (id <= 251) return 2;
    if (id <= 386) return 3;
    if (id <= 493) return 4;
    if (id <= 649) return 5;
    if (id <= 721) return 6;
    if (id <= 809) return 7;
    if (id <= 905) return 8;
    return 9;
  }

  // Obtener nombre de generación
  static String getGenerationName(int generation) {
    const generationNames = {
      1: 'Kanto',
      2: 'Johto',
      3: 'Hoenn',
      4: 'Sinnoh',
      5: 'Unova',
      6: 'Kalos',
      7: 'Alola',
      8: 'Galar',
      9: 'Paldea',
    };
    return generationNames[generation] ?? 'Desconocida';
  }

  // Calcular nivel de rareza basado en estadísticas
  static String calculateRarity(Map<String, int> stats) {
    final total = calculateBaseStatTotal(stats);

    if (total >= 600) return 'Legendario';
    if (total >= 540) return 'Pseudo-Legendario';
    if (total >= 500) return 'Raro';
    if (total >= 450) return 'Poco Común';
    return 'Común';
  }

  // Verificar si es Pokémon legendario por ID
  static bool isLegendaryPokemon(int id) {
    const legendaryIds = [
      144, 145, 146, 150, 151, // Gen 1
      243, 244, 245, 249, 250, 251, // Gen 2
      377, 378, 379, 380, 381, 382, 383, 384, 385, 386, // Gen 3
      480,
      481,
      482,
      483,
      484,
      485,
      486,
      487,
      488,
      489,
      490,
      491,
      492,
      493, // Gen 4
      494, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, // Gen 5
    ];
    return legendaryIds.contains(id);
  }

  // Verificar si es Pokémon mítico por ID
  static bool isMythicalPokemon(int id) {
    const mythicalIds = [
      151,
      251,
      385,
      386,
      489,
      490,
      491,
      492,
      493,
      494,
      647,
      648,
      649,
    ];
    return mythicalIds.contains(id);
  }

  // Obtener color de rareza
  static String getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'común':
        return '#9E9E9E';
      case 'poco común':
        return '#4CAF50';
      case 'raro':
        return '#2196F3';
      case 'pseudo-legendario':
        return '#9C27B0';
      case 'legendario':
        return '#FF9800';
      case 'mítico':
        return '#E91E63';
      default:
        return '#9E9E9E';
    }
  }

  // Calcular experiencia base por nivel
  static int calculateExperienceForLevel(int level, String growthRate) {
    switch (growthRate.toLowerCase()) {
      case 'fast':
        return (0.8 * pow(level, 3)).round();
      case 'medium':
        return pow(level, 3).round();
      case 'slow':
        return (1.25 * pow(level, 3)).round();
      case 'medium-slow':
        return ((6 / 5) * pow(level, 3) -
                15 * pow(level, 2) +
                100 * level -
                140)
            .round();
      case 'erratic':
        if (level <= 50) {
          return ((pow(level, 3) * (100 - level)) / 50).round();
        } else if (level <= 68) {
          return ((pow(level, 3) * (150 - level)) / 100).round();
        } else if (level <= 98) {
          return ((pow(level, 3) * ((1911 - 10 * level) / 3)) / 500).round();
        } else {
          return ((pow(level, 3) * (160 - level)) / 100).round();
        }
      case 'fluctuating':
        if (level <= 15) {
          return ((pow(level, 3) * ((24 + ((level + 1) / 3))) / 50)).round();
        } else if (level <= 36) {
          return ((pow(level, 3) * (14 + level)) / 50).round();
        } else {
          return ((pow(level, 3) * ((32 + (level / 2))) / 50)).round();
        }
      default:
        return pow(level, 3).round();
    }
  }

  // Validar ID de Pokémon
  static bool isValidPokemonId(int id) {
    return id >= 1 && id <= 1010;
  }

  // Obtener URL de imagen por ID
  static String getPokemonImageUrl(int id, {bool shiny = false}) {
    final baseUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';
    if (shiny) {
      return '$baseUrl/shiny/$id.png';
    }
    return '$baseUrl/$id.png';
  }

  // Obtener URL de sprite animado
  static String getPokemonAnimatedSpriteUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif';
  }

  // Formatear tiempo de captura
  static String formatCaptureTime(DateTime captureTime) {
    final now = DateTime.now();
    final difference = now.difference(captureTime);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  // Generar equipo aleatorio
  static List<int> generateRandomTeam({int size = 6}) {
    final random = Random();
    final team = <int>[];

    while (team.length < size) {
      final id = random.nextInt(1010) + 1;
      if (!team.contains(id)) {
        team.add(id);
      }
    }

    return team;
  }
}
