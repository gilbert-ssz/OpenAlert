import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Collapsing app bar with a fishpond photograph and a green overlay so the
/// text stays readable.
class PhotoHeader extends StatelessWidget {
  const PhotoHeader({
    super.key,
    required this.image,
    required this.title,
    this.eyebrow,
    this.actions,
    this.expandedHeight = 230,
    this.automaticallyImplyLeading = false,
  });

  final String image;
  final String title;

  /// Small content shown above the title (e.g. connection badge).
  final Widget? eyebrow;
  final List<Widget>? actions;
  final double expandedHeight;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: expandedHeight,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: AppColors.deepGreen,
      foregroundColor: Colors.white,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            EdgeInsetsDirectional.only(
                start: 20, bottom: 14, end: actions == null ? 20 : 64),
        expandedTitleScale: 1.35,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.deepGreen.withValues(alpha: 0.45),
                    AppColors.deepGreen.withValues(alpha: 0.05),
                    AppColors.deepGreen.withValues(alpha: 0.88),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
            if (eyebrow != null)
              Positioned(left: 20, right: 20, bottom: 58, child: eyebrow!),
          ],
        ),
      ),
    );
  }
}
