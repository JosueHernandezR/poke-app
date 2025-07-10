import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/pokemon_colors.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../data/repositories/pokemon_repository_impl.dart';
import '../bloc/pokemon_bloc.dart';

class PokemonSearchPage extends StatefulWidget {
  const PokemonSearchPage({super.key});

  @override
  State<PokemonSearchPage> createState() => _PokemonSearchPageState();
}

class _PokemonSearchPageState extends State<PokemonSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<String> _selectedTypes = [];
  String _selectedGeneration = 'Todas';

  // Lista de búsquedas recientes (simplificada)
  final List<String> _recentSearches = ['Pikachu', 'Charizard', 'Mewtwo'];

  // Contexto del BLoC para uso en listeners
  BuildContext? _blocContext;

  @override
  void initState() {
    super.initState();
  }

  void _initializePokemonData(BuildContext context) {
    // Cargar la lista inicial de Pokémon para poder buscar localmente
    // Usar más Pokémon para tener una mejor base de búsqueda
    context.read<PokemonBloc>().add(
      const LoadPokemonListEvent(offset: 0, limit: 300),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PokemonBloc>(),
      child: Builder(
        builder: (context) {
          // Guardar el contexto para uso en listeners
          _blocContext = context;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _searchFocusNode.requestFocus();
            _initializePokemonData(context);
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Buscar Pokémon'),
              actions: [
                // Botón temporal para limpiar caché
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () async {
                    // Limpiar caché
                    final repository = di.sl<PokemonRepository>();
                    if (repository is PokemonRepositoryImpl) {
                      await repository.clearCache();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Caché limpiado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  tooltip: 'Limpiar caché',
                ),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => _showFiltersBottomSheet(context),
                ),
              ],
            ),
            body: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      // Búsqueda directa en tiempo real
                      if (_blocContext != null) {
                        print('🔍 ON CHANGED: Nuevo valor: "$value"');
                        _blocContext!.read<PokemonBloc>().add(
                          LocalSearchEvent(
                            query: value.trim(),
                            selectedTypes: _selectedTypes,
                          ),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o número...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  // Limpiar búsqueda cuando se presiona clear
                                  if (_blocContext != null) {
                                    _blocContext!.read<PokemonBloc>().add(
                                      const LocalSearchEvent(
                                        query: '',
                                        selectedTypes: [],
                                      ),
                                    );
                                  }
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Active Filters
                if (_selectedTypes.isNotEmpty || _selectedGeneration != 'Todas')
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Type filters
                        ..._selectedTypes.map((type) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(type.toUpperCase()),
                              backgroundColor: PokemonColors.getTypeColor(
                                type,
                              ).withOpacity(0.2),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _selectedTypes.remove(type);
                                });

                                // Actualizar la búsqueda cuando se quita un filtro
                                _blocContext?.read<PokemonBloc>().add(
                                  LocalSearchEvent(
                                    query: _searchController.text.trim(),
                                    selectedTypes: _selectedTypes,
                                  ),
                                );
                              },
                              onSelected: (selected) {},
                            ),
                          );
                        }),

                        // Generation filter
                        if (_selectedGeneration != 'Todas')
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_selectedGeneration),
                              backgroundColor: Colors.blue.withOpacity(0.2),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _selectedGeneration = 'Todas';
                                });

                                // Actualizar la búsqueda cuando se quita el filtro de generación
                                _blocContext?.read<PokemonBloc>().add(
                                  LocalSearchEvent(
                                    query: _searchController.text.trim(),
                                    selectedTypes: _selectedTypes,
                                  ),
                                );
                              },
                              onSelected: (selected) {},
                            ),
                          ),
                      ],
                    ),
                  ),

                // Content
                Expanded(
                  child: BlocListener<PokemonBloc, PokemonState>(
                    listener: (context, state) {
                      // Cuando se cargan los datos iniciales, aplicar búsqueda si hay texto
                      if (state is PokemonListLoaded &&
                          _searchController.text.trim().isNotEmpty) {
                        // Aplicar la búsqueda actual a los datos recién cargados
                        context.read<PokemonBloc>().add(
                          LocalSearchEvent(
                            query: _searchController.text.trim(),
                            selectedTypes: _selectedTypes,
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<PokemonBloc, PokemonState>(
                      builder: (context, state) {
                        if (state is PokemonLoading) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Buscando Pokémon...'),
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
                                Text(
                                  'Error: ${state.message}',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    final query = _searchController.text.trim();
                                    if (query.isNotEmpty) {
                                      context.read<PokemonBloc>().add(
                                        SearchPokemonEvent(query: query),
                                      );
                                    }
                                  },
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is PokemonSearchLoaded) {
                          if (state.searchResults.isEmpty &&
                              state.query.isNotEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron resultados para "${state.query}"',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Intenta con otro nombre o número',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state.searchResults.isNotEmpty) {
                            return _buildSearchResults(state.searchResults);
                          }
                        }

                        // Estado inicial (PokemonInitial) o búsqueda vacía - mostrar sugerencias
                        return _buildEmptyState();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Search Suggestions
          Text(
            'Búsquedas Rápidas',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSearchChip('Pikachu', Icons.electric_bolt),
              _buildQuickSearchChip('Charizard', Icons.local_fire_department),
              _buildQuickSearchChip('Blastoise', Icons.water_drop),
              _buildQuickSearchChip('Venusaur', Icons.grass),
              _buildQuickSearchChip('Mewtwo', Icons.star),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'Búsquedas Recientes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._recentSearches.map((search) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.history, color: Colors.white),
                ),
                title: Text(search),
                trailing: const Icon(Icons.north_west),
                onTap: () {
                  _searchController.text = search;
                },
              );
            }).toList(),
          ],

          const SizedBox(height: 32),

          // Search Tips
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Consejos de Búsqueda',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• Busca por nombre: "Pikachu"'),
                  const Text('• Busca por número: "25"'),
                  const Text('• La búsqueda no distingue mayúsculas'),
                  const Text('• Prueba con nombres en inglés'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
      },
    );
  }

  Widget _buildSearchResults(List pokemonList) {
    return ListView.builder(
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
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.catching_pokemon, color: typeColor);
                },
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
            onTap: () {
              // Agregar a búsquedas recientes
              _addToRecentSearches(pokemon.name);

              context.push('/home/pokemon/${pokemon.id}');
            },
          ),
        );
      },
    );
  }

  void _addToRecentSearches(String pokemonName) {
    setState(() {
      _recentSearches.removeWhere((item) => item == pokemonName);
      _recentSearches.insert(0, pokemonName);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filtros',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedTypes.clear();
                                _selectedGeneration = 'Todas';
                              });
                              setState(() {});
                            },
                            child: const Text('Limpiar'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Types Filter
                      Text(
                        'Tipos',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            PokemonColors.typeColors.keys.map((type) {
                              final isSelected = _selectedTypes.contains(type);
                              return FilterChip(
                                label: Text(type.toUpperCase()),
                                selected: isSelected,
                                backgroundColor: PokemonColors.getTypeColor(
                                  type,
                                ).withOpacity(0.2),
                                selectedColor: PokemonColors.getTypeColor(
                                  type,
                                ).withOpacity(0.5),
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      _selectedTypes.add(type);
                                    } else {
                                      _selectedTypes.remove(type);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 40),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {});

                            // Aplicar los filtros usando el nuevo evento
                            _blocContext?.read<PokemonBloc>().add(
                              LocalSearchEvent(
                                query: _searchController.text.trim(),
                                selectedTypes: _selectedTypes,
                              ),
                            );
                          },
                          child: const Text('Aplicar Filtros'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
