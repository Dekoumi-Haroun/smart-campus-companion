import 'package:flutter/material.dart';

import 'widgets/announcements_preview.dart';
import 'widgets/bottom_action_buttons.dart';
import 'widgets/current_class_card.dart';
import 'widgets/home_header.dart';
import 'widgets/stats_summary_row.dart';
import 'widgets/upcoming_events_preview.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList.list(
                children: [
                  HomeHeader(theme: theme),
                  const SizedBox(height: 20),
                  const CurrentClassCard(),
                  const SizedBox(height: 20),
                  const StatsSummaryRow(),
                  const SizedBox(height: 24),
                  const AnnouncementsPreview(),
                  const SizedBox(height: 24),
                  const UpcomingEventsPreview(),
                  const SizedBox(height: 24),
                  const BottomActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
