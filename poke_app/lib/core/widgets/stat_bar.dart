import 'package:flutter/material.dart';
import '../theme/pokemon_colors.dart';
import '../utils/pokemon_helpers.dart';

class StatBar extends StatelessWidget {
  final String statName;
  final int statValue;
  final int maxValue;
  final Color? color;
  final bool showValue;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;

  const StatBar({
    super.key,
    required this.statName,
    required this.statValue,
    this.maxValue = 255,
    this.color,
    this.showValue = true,
    this.showPercentage = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (statValue / maxValue).clamp(0.0, 1.0);
    final statColor = color ?? _getStatColor(statName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatStatName(statName),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (showValue)
                Row(
                  children: [
                    Text(
                      statValue.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statColor,
                        fontSize: 14,
                      ),
                    ),
                    if (showPercentage) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${(percentage * 100).toInt()}%)',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child:
                  animated
                      ? TweenAnimationBuilder<double>(
                        duration: animationDuration,
                        tween: Tween(begin: 0.0, end: percentage),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              statColor,
                            ),
                          );
                        },
                      )
                      : LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(statColor),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatColor(String statName) {
    switch (statName.toLowerCase()) {
      case 'hp':
        return PokemonColors.hp;
      case 'attack':
        return PokemonColors.attack;
      case 'defense':
        return PokemonColors.defense;
      case 'special-attack':
      case 'sp. atk':
        return PokemonColors.specialAttack;
      case 'special-defense':
      case 'sp. def':
        return PokemonColors.specialDefense;
      case 'speed':
        return PokemonColors.speed;
      default:
        return Colors.grey;
    }
  }

  String _formatStatName(String statName) {
    switch (statName.toLowerCase()) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Ataque';
      case 'defense':
        return 'Defensa';
      case 'special-attack':
        return 'At. Esp.';
      case 'special-defense':
        return 'Def. Esp.';
      case 'speed':
        return 'Velocidad';
      default:
        return PokemonHelpers.capitalize(statName);
    }
  }
}

class StatsChart extends StatelessWidget {
  final Map<String, int> stats;
  final bool showTotal;
  final bool animated;
  final Duration animationDuration;

  const StatsChart({
    super.key,
    required this.stats,
    this.showTotal = true,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    final total = PokemonHelpers.calculateBaseStatTotal(stats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...stats.entries.map((entry) {
          return StatBar(
            statName: entry.key,
            statValue: entry.value,
            animated: animated,
            animationDuration: animationDuration,
          );
        }).toList(),
        if (showTotal) ...[
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                total.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class StatComparison extends StatelessWidget {
  final String statName;
  final int value1;
  final int value2;
  final String? label1;
  final String? label2;
  final Color? color1;
  final Color? color2;

  const StatComparison({
    super.key,
    required this.statName,
    required this.value1,
    required this.value2,
    this.label1,
    this.label2,
    this.color1,
    this.color2,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [value1, value2].reduce((a, b) => a > b ? a : b);
    final percentage1 = (value1 / maxValue).clamp(0.0, 1.0);
    final percentage2 = (value2 / maxValue).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label1 ?? 'Pokémon 1',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          value1.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color1 ?? Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage1,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color1 ?? Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label2 ?? 'Pokémon 2',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          value2.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color2 ?? Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage2,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color2 ?? Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularStatIndicator extends StatelessWidget {
  final String statName;
  final int statValue;
  final int maxValue;
  final Color? color;
  final double size;

  const CircularStatIndicator({
    super.key,
    required this.statName,
    required this.statValue,
    this.maxValue = 255,
    this.color,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (statValue / maxValue).clamp(0.0, 1.0);
    final statColor = color ?? Colors.blue;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(statColor),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statValue.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.2,
                    color: statColor,
                  ),
                ),
                Text(
                  statName,
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
