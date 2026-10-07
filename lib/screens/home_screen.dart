import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';
import '../data/sync.dart';
import '../widgets/action_strip.dart';
import '../widgets/delta_card.dart';
import '../widgets/lifetime_strip.dart';
import '../widgets/network_toggle.dart';
import '../widgets/surge_banner.dart';
import '../widgets/top_bar.dart';
import 'sos_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncRunnerProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopBar(),
                  const SizedBox(height: 16),
                  const SurgeBanner(),
                  const SizedBox(height: 20),
                  const LifetimeStrip(),
                  const SizedBox(height: 6),
                  Text('Tap a dot to see visit history',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: context.mutedTxt)),
                  const SizedBox(height: 22),
                  const DeltaCard(),
                  const Spacer(),
                  Row(children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SosScreen())),
                      icon: const Icon(Icons.warning_amber, size: 18),
                      label: const Text('Responder view (demo)'),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Switch theme',
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                        size: 20, color: context.mutedTxt),
                      onPressed: () => ref.read(themeModeProvider.notifier).state =
                        isDark ? ThemeMode.light : ThemeMode.dark,
                    ),
                    const NetworkToggle(),
                  ]),
                  const SizedBox(height: 8),
                  const ActionStrip(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}