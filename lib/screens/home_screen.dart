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
    ref.watch(syncRunnerProvider); // keeps the fake sync alive
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopBar(),
                  const SizedBox(height: 14),
                  const SurgeBanner(),
                  const SizedBox(height: 18),
                  const LifetimeStrip(),
                  const SizedBox(height: 18),
                  const DeltaCard(),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SosScreen()),
                        ),
                        child: const Text('Responder view (demo)'),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Switch light / dark',
                            icon: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                size: 20,
                                color: context.mutedTxt),
                            onPressed: () => ref
                                .read(themeModeProvider.notifier)
                                .state =
                                isDark ? ThemeMode.light : ThemeMode.dark,
                          ),
                          const NetworkToggle(),
                        ],
                      ),
                    ],
                  ),
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