import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';
import '../widgets/action_strip.dart';
import '../widgets/delta_card.dart';
import '../widgets/lifetime_strip.dart';
import '../widgets/network_toggle.dart';
import '../widgets/surge_banner.dart';
import '../widgets/top_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncRunnerProvider); // keeps the fake sync alive
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  TopBar(),
                  SizedBox(height: 16),
                  SurgeBanner(),
                  SizedBox(height: 20),
                  LifetimeStrip(),
                  SizedBox(height: 28),
                  DeltaCard(),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: NetworkToggle(),
                  ),
                  SizedBox(height: 8),
                  ActionStrip(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}