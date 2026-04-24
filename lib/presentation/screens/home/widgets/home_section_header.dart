import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        TextButton(onPressed: onSeeAll, child: const Text(AppStrings.seeAll)),
      ],
    );
  }
}
