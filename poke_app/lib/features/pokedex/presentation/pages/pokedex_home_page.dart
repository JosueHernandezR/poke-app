import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/pokemon_colors.dart';
import '../bloc/pokemon_bloc.dart';

class PokedexHomePage extends StatefulWidget {
  const PokedexHomePage({super.key});

  @override
  State<PokedexHomePage> createState() => _PokedexHomePageState();
}

class _PokedexHomePageState extends State<PokedexHomePage> {
  bool _isGridView = true;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              di.sl<PokemonBloc>()
                ..add(const LoadPokemonListEvent(offset: 0, limit: 20)),
      child: Builder(
        builder: (context) {
          // Configurar scroll listener
          _scrollController.addListener(() {
            if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200) {
              final currentState = context.read<PokemonBloc>().state;
              if (currentState is PokemonListLoaded &&
                  currentState.hasMore &&
                  !currentState.isLoadingMore) {
                context.read<PokemonBloc>().add(const LoadMorePokemonEvent());
              }
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Pokédex'),
              actions: [
                IconButton(
                  icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.go('/home/search'),
                ),
              ],
            ),
            body: BlocBuilder<PokemonBloc, PokemonState>(
              builder: (context, state) {
                if (state is PokemonLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando Pokémon...'),
                      ],
                    ),
                  );
                }

                if (state is PokemonError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => context.read<PokemonBloc>().add(
                                const LoadPokemonListEvent(
                                  offset: 0,
                                  limit: 20,
                                ),
                              ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PokemonListLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PokemonBloc>().add(
                        const RefreshPokemonListEvent(),
                      );
                    },
                    child: Stack(
                      children: [
                        _isGridView
                            ? _buildGridView(state.pokemonList)
                            : _buildListView(state.pokemonList),
                        if (state.isLoadingMore)
                          const Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Cargando más...'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('No hay datos disponibles'));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List pokemonList) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = pokemonList[index];
        final primaryType =
            pokemon.types.isNotEmpty ? pokemon.types[0] : 'normal';
        final typeColor = PokemonColors.getTypeColor(primaryType);

        return Card(
          child: InkWell(
            onTap: () => context.push('/home/pokemon/${pokemon.id}'),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    typeColor.withOpacity(0.1),
                    typeColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.catching_pokemon,
                            size: 48,
                            color: typeColor,
                          ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pokemon.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children:
                                pokemon.types.take(2).map<Widget>((type) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: PokemonColors.getTypeColor(type),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      type.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(List pokemonList) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = pokemonList[index];
        final primaryType =
            pokemon.types.isNotEmpty ? pokemon.types[0] : 'normal';
        final typeColor = PokemonColors.getTypeColor(primaryType);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: typeColor.withOpacity(0.1),
              child: Image.network(
                pokemon.imageUrl,
                width: 32,
                height: 32,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Icon(Icons.catching_pokemon, color: typeColor),
              ),
            ),
            title: Text(
              pokemon.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('#${pokemon.id.toString().padLeft(3, '0')}'),
            trailing: Wrap(
              spacing: 4,
              children:
                  pokemon.types.take(2).map<Widget>((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PokemonColors.getTypeColor(type),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            onTap: () => context.push('/home/pokemon/${pokemon.id}'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
