import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/app_state.dart';
import 'screens/home_screen.dart';

void main() => runApp(const ProviderScope(child: ShapapApp()));

class ShapapApp extends ConsumerWidget {
  const ShapapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const seed = Color(0xFF0F766E);
    return MaterialApp(
      title: 'Shapap',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeModeProvider),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}