import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación de pantalla
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar inyección de dependencias
  await di.init();

  // Ejecutar aplicación
  runApp(const PokeApp());
}

class PokeApp extends StatelessWidget {
  const PokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pokédex App',
      debugShowCheckedModeBanner: false,

      // Configuración de tema
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Configuración de router
      routerConfig: AppRouter.router,
    );
  }
}
