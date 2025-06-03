import 'package:flutter/material.dart';

import '../../../../core/theme/pokemon_colors.dart';

class PokemonDetailPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailPage({super.key, required this.pokemonId});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  // Mock data - En la implementación real vendrá del BLoC
  late Map<String, dynamic> _pokemon;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPokemonData();
  }

  void _loadPokemonData() {
    // Mock data
    _pokemon = {
      'id': widget.pokemonId,
      'name': 'Charizard',
      'types': ['fire', 'flying'],
      'height': 17,
      'weight': 905,
      'description':
          'Escupe fuego que es tan caliente que puede derretir cualquier cosa. Su fuego se vuelve más intenso cuando tiene experiencia en batalla.',
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${widget.pokemonId}.png',
      'stats': {
        'hp': 78,
        'attack': 84,
        'defense': 78,
        'special-attack': 109,
        'special-defense': 85,
        'speed': 100,
      },
      'abilities': ['Blaze', 'Solar Power'],
      'evolutions': [
        {'id': 4, 'name': 'Charmander', 'level': 1},
        {'id': 5, 'name': 'Charmeleon', 'level': 16},
        {'id': 6, 'name': 'Charizard', 'level': 36},
      ],
      'moves': [
        {'name': 'Flamethrower', 'type': 'fire', 'power': 90},
        {'name': 'Dragon Claw', 'type': 'dragon', 'power': 80},
        {'name': 'Air Slash', 'type': 'flying', 'power': 75},
        {'name': 'Solar Beam', 'type': 'grass', 'power': 120},
      ],
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryType = _pokemon['types'][0];
    final typeColor = PokemonColors.getTypeColor(primaryType);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: typeColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: PokemonColors.getTypeGradient(primaryType),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      // Pokemon Image
                      Hero(
                        tag: 'pokemon-${widget.pokemonId}',
                        child: Image.network(
                          _pokemon['imageUrl'],
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.catching_pokemon,
                                size: 100,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // TODO: Implementar compartir
                  },
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            // Pokemon Info Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${_pokemon['id'].toString().padLeft(3, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _pokemon['name'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Types
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children:
                            _pokemon['types'].map<Widget>((type) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: PokemonColors.getTypeColor(type),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  type.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Basic Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Altura',
                          '${(_pokemon['height'] / 10).toStringAsFixed(1)} m',
                          Icons.height,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Peso',
                          '${(_pokemon['weight'] / 10).toStringAsFixed(1)} kg',
                          Icons.monitor_weight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Habilidades',
                          '${_pokemon['abilities'].length}',
                          Icons.star,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: typeColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: typeColor,
              tabs: const [
                Tab(text: 'Stats'),
                Tab(text: 'Evolución'),
                Tab(text: 'Movimientos'),
                Tab(text: 'Info'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStatsTab(),
                  _buildEvolutionTab(),
                  _buildMovesTab(),
                  _buildInfoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Estadísticas Base',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._pokemon['stats'].entries.map((stat) {
          return _buildStatBar(stat.key, stat.value);
        }).toList(),
      ],
    );
  }

  Widget _buildStatBar(String statName, int value) {
    final statColors = {
      'hp': PokemonColors.hp,
      'attack': PokemonColors.attack,
      'defense': PokemonColors.defense,
      'special-attack': PokemonColors.specialAttack,
      'special-defense': PokemonColors.specialDefense,
      'speed': PokemonColors.speed,
    };

    final color = statColors[statName] ?? Colors.grey;
    final percentage = value / 255.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statName.replaceAll('-', ' ').toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Cadena Evolutiva',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              _pokemon['evolutions'].map<Widget>((evolution) {
                final isCurrentPokemon = evolution['id'] == widget.pokemonId;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isCurrentPokemon
                                  ? PokemonColors.pokeball.withOpacity(0.1)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border:
                              isCurrentPokemon
                                  ? Border.all(
                                    color: PokemonColors.pokeball,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Image.network(
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${evolution['id']}.png',
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.catching_pokemon,
                              size: 80,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evolution['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isCurrentPokemon ? PokemonColors.pokeball : null,
                        ),
                      ),
                      Text(
                        'Nivel ${evolution['level']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildMovesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Movimientos',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._pokemon['moves'].map((move) {
          final typeColor = PokemonColors.getTypeColor(move['type']);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                move['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Poder: ${move['power']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  move['type'].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Información',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descripción',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _pokemon['description'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Habilidades',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      _pokemon['abilities'].map<Widget>((ability) {
                        return Chip(
                          label: Text(ability),
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
