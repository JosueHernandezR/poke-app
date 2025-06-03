import 'package:flutter/material.dart';

class PokemonColors {
  // Colores principales
  static const Color pokeball = Color(0xFFE53E3E);
  static const Color pokeballWhite = Color(0xFFFFFFFF);
  static const Color pokeballBlack = Color(0xFF2D3748);

  // Colores por tipo de Pokémon
  static const Map<String, Color> typeColors = {
    'normal': Color(0xFFA8A878),
    'fire': Color(0xFFF08030),
    'water': Color(0xFF6890F0),
    'electric': Color(0xFFF8D030),
    'grass': Color(0xFF78C850),
    'ice': Color(0xFF98D8D8),
    'fighting': Color(0xFFC03028),
    'poison': Color(0xFFA040A0),
    'ground': Color(0xFFE0C068),
    'flying': Color(0xFFA890F0),
    'psychic': Color(0xFFF85888),
    'bug': Color(0xFFA8B820),
    'rock': Color(0xFFB8A038),
    'ghost': Color(0xFF705898),
    'dragon': Color(0xFF7038F8),
    'dark': Color(0xFF705848),
    'steel': Color(0xFFB8B8D0),
    'fairy': Color(0xFFEE99AC),
  };

  // Colores de estadísticas
  static const Color hp = Color(0xFFFF5959);
  static const Color attack = Color(0xFFF5AC78);
  static const Color defense = Color(0xFFFAE078);
  static const Color specialAttack = Color(0xFF9DB7F5);
  static const Color specialDefense = Color(0xFFA7DB8D);
  static const Color speed = Color(0xFFFA92B2);

  // Colores de rareza
  static const Color common = Color(0xFF9E9E9E);
  static const Color uncommon = Color(0xFF4CAF50);
  static const Color rare = Color(0xFF2196F3);
  static const Color epic = Color(0xFF9C27B0);
  static const Color legendary = Color(0xFFFF9800);
  static const Color mythical = Color(0xFFE91E63);

  // Gradientes
  static const LinearGradient pokeballGradient = LinearGradient(
    colors: [pokeball, Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shinyGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Método para obtener color por tipo
  static Color getTypeColor(String type) {
    return typeColors[type.toLowerCase()] ?? typeColors['normal']!;
  }

  // Método para obtener gradiente por tipo
  static LinearGradient getTypeGradient(String type) {
    final baseColor = getTypeColor(type);
    return LinearGradient(
      colors: [baseColor, baseColor.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
