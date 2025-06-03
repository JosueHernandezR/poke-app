import 'package:flutter/material.dart';
import '../constants/pokemon_types.dart';

class PokemonTypeBadge extends StatelessWidget {
  final String type;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;
  final double? iconSize;

  const PokemonTypeBadge({
    super.key,
    required this.type,
    this.fontSize = 12,
    this.padding,
    this.showIcon = false,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = PokemonTypes.getTypeColor(type);
    final typeIcon = PokemonTypes.getTypeIcon(type);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(typeIcon, size: iconSize, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            type.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonTypesList extends StatelessWidget {
  final List<String> types;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcons;
  final double? iconSize;
  final MainAxisAlignment alignment;
  final double spacing;

  const PokemonTypesList({
    super.key,
    required this.types,
    this.fontSize = 12,
    this.padding,
    this.showIcons = false,
    this.iconSize = 16,
    this.alignment = MainAxisAlignment.start,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children:
          types.map((type) {
            final isLast = type == types.last;
            return Row(
              children: [
                PokemonTypeBadge(
                  type: type,
                  fontSize: fontSize,
                  padding: padding,
                  showIcon: showIcons,
                  iconSize: iconSize,
                ),
                if (!isLast) SizedBox(width: spacing),
              ],
            );
          }).toList(),
    );
  }
}

class PokemonTypeChip extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? fontSize;

  const PokemonTypeChip({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = PokemonTypes.getTypeColor(type);
    final typeIcon = PokemonTypes.getTypeIcon(type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? typeColor : typeColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: typeColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              typeIcon,
              size: 16,
              color: isSelected ? Colors.white : typeColor,
            ),
            const SizedBox(width: 6),
            Text(
              type.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : typeColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypeEffectivenessIndicator extends StatelessWidget {
  final String attackingType;
  final List<String> defendingTypes;
  final bool showLabel;

  const TypeEffectivenessIndicator({
    super.key,
    required this.attackingType,
    required this.defendingTypes,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveness = PokemonTypes.getMultiTypeEffectiveness(
      attackingType,
      defendingTypes,
    );
    final description = PokemonTypes.getEffectivenessDescription(effectiveness);
    final color = PokemonTypes.getEffectivenessColor(effectiveness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              '${effectiveness}x',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(description, style: TextStyle(color: color, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}
