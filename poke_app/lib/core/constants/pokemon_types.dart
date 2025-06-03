import 'package:flutter/material.dart';
import '../theme/pokemon_colors.dart';

class PokemonTypes {
  // Lista de todos los tipos
  static const List<String> allTypes = [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];

  // Iconos para cada tipo
  static final Map<String, IconData> typeIcons = {
    'normal': Icons.circle,
    'fire': Icons.local_fire_department,
    'water': Icons.water_drop,
    'electric': Icons.electric_bolt,
    'grass': Icons.grass,
    'ice': Icons.ac_unit,
    'fighting': Icons.sports_martial_arts,
    'poison': Icons.science,
    'ground': Icons.landscape,
    'flying': Icons.air,
    'psychic': Icons.psychology,
    'bug': Icons.bug_report,
    'rock': Icons.terrain,
    'ghost': Icons.visibility_off,
    'dragon': Icons.pets,
    'dark': Icons.dark_mode,
    'steel': Icons.hardware,
    'fairy': Icons.auto_awesome,
  };

  // Efectividad de tipos (súper efectivo)
  static const Map<String, List<String>> superEffective = {
    'normal': [],
    'fire': ['grass', 'ice', 'bug', 'steel'],
    'water': ['fire', 'ground', 'rock'],
    'electric': ['water', 'flying'],
    'grass': ['water', 'ground', 'rock'],
    'ice': ['grass', 'ground', 'flying', 'dragon'],
    'fighting': ['normal', 'ice', 'rock', 'dark', 'steel'],
    'poison': ['grass', 'fairy'],
    'ground': ['fire', 'electric', 'poison', 'rock', 'steel'],
    'flying': ['electric', 'ice', 'rock'],
    'psychic': ['fighting', 'poison'],
    'bug': ['grass', 'psychic', 'dark'],
    'rock': ['fire', 'ice', 'flying', 'bug'],
    'ghost': ['psychic', 'ghost'],
    'dragon': ['dragon'],
    'dark': ['fighting', 'bug', 'fairy'],
    'steel': ['ice', 'rock', 'fairy'],
    'fairy': ['fire', 'poison', 'steel'],
  };

  // Efectividad de tipos (no muy efectivo)
  static const Map<String, List<String>> notVeryEffective = {
    'normal': ['rock', 'steel'],
    'fire': ['fire', 'water', 'rock', 'dragon'],
    'water': ['water', 'grass', 'dragon'],
    'electric': ['electric', 'grass', 'dragon'],
    'grass': ['fire', 'grass', 'poison', 'flying', 'bug', 'dragon', 'steel'],
    'ice': ['fire', 'water', 'ice', 'steel'],
    'fighting': ['poison', 'flying', 'psychic', 'bug', 'fairy'],
    'poison': ['poison', 'ground', 'rock', 'ghost'],
    'ground': ['grass', 'bug'],
    'flying': ['electric', 'rock', 'steel'],
    'psychic': ['psychic', 'steel'],
    'bug': ['fire', 'fighting', 'poison', 'flying', 'ghost', 'steel', 'fairy'],
    'rock': ['fighting', 'ground', 'steel'],
    'ghost': ['dark'],
    'dragon': ['steel'],
    'dark': ['fighting', 'dark', 'fairy'],
    'steel': ['fire', 'water', 'electric', 'steel'],
    'fairy': ['fire', 'poison', 'steel'],
  };

  // Efectividad de tipos (sin efecto)
  static const Map<String, List<String>> noEffect = {
    'normal': ['ghost'],
    'electric': ['ground'],
    'fighting': ['ghost'],
    'poison': ['steel'],
    'ground': ['flying'],
    'psychic': ['dark'],
    'ghost': ['normal'],
  };

  // Obtener color del tipo
  static Color getTypeColor(String type) {
    return PokemonColors.getTypeColor(type);
  }

  // Obtener icono del tipo
  static IconData getTypeIcon(String type) {
    return typeIcons[type.toLowerCase()] ?? Icons.help;
  }

  // Calcular efectividad de un tipo contra otro
  static double getTypeEffectiveness(
    String attackingType,
    String defendingType,
  ) {
    attackingType = attackingType.toLowerCase();
    defendingType = defendingType.toLowerCase();

    if (noEffect[attackingType]?.contains(defendingType) == true) {
      return 0.0;
    }

    if (superEffective[attackingType]?.contains(defendingType) == true) {
      return 2.0;
    }

    if (notVeryEffective[attackingType]?.contains(defendingType) == true) {
      return 0.5;
    }

    return 1.0;
  }

  // Calcular efectividad contra múltiples tipos
  static double getMultiTypeEffectiveness(
    String attackingType,
    List<String> defendingTypes,
  ) {
    double effectiveness = 1.0;

    for (String defendingType in defendingTypes) {
      effectiveness *= getTypeEffectiveness(attackingType, defendingType);
    }

    return effectiveness;
  }

  // Obtener tipos débiles contra un tipo específico
  static List<String> getWeakAgainst(String type) {
    List<String> weakTypes = [];

    for (String defendingType in allTypes) {
      if (getTypeEffectiveness(type, defendingType) > 1.0) {
        weakTypes.add(defendingType);
      }
    }

    return weakTypes;
  }

  // Obtener tipos resistentes contra un tipo específico
  static List<String> getResistantAgainst(String type) {
    List<String> resistantTypes = [];

    for (String defendingType in allTypes) {
      if (getTypeEffectiveness(type, defendingType) < 1.0) {
        resistantTypes.add(defendingType);
      }
    }

    return resistantTypes;
  }

  // Obtener descripción de efectividad
  static String getEffectivenessDescription(double effectiveness) {
    if (effectiveness == 0.0) {
      return 'Sin efecto';
    } else if (effectiveness == 0.25) {
      return 'Muy poco efectivo';
    } else if (effectiveness == 0.5) {
      return 'Poco efectivo';
    } else if (effectiveness == 1.0) {
      return 'Efectivo';
    } else if (effectiveness == 2.0) {
      return 'Súper efectivo';
    } else if (effectiveness == 4.0) {
      return 'Extremadamente efectivo';
    } else {
      return 'Efectivo';
    }
  }

  // Obtener color de efectividad
  static Color getEffectivenessColor(double effectiveness) {
    if (effectiveness == 0.0) {
      return Colors.grey;
    } else if (effectiveness < 1.0) {
      return Colors.red;
    } else if (effectiveness == 1.0) {
      return Colors.grey;
    } else {
      return Colors.green;
    }
  }
}
