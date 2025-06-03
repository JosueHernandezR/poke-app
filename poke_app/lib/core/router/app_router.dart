import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/pokedex/presentation/pages/pokedex_home_page.dart';
import '../../features/pokedex/presentation/pages/pokemon_detail_page.dart';
import '../../features/pokedex/presentation/pages/pokemon_search_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const PokedexHomePage(),
        routes: [
          GoRoute(
            path: '/pokemon/:id',
            name: 'pokemon-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PokemonDetailPage(pokemonId: int.parse(id));
            },
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const PokemonSearchPage(),
          ),
        ],
      ),
    ],

    // Manejo de errores
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Página no encontrada',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'La página que buscas no existe',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Ir al inicio'),
                ),
              ],
            ),
          ),
        ),
  );
}
