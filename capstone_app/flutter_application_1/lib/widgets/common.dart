import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/sensor_reading.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';

/// White rounded card with a soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = Colors.white,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Colored information strip (demo notice, warnings, tips).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: color, fontSize: 15.5)),
                const SizedBox(height: 2),
                Text(message,
                    style: const TextStyle(
                        color: AppColors.ink, fontSize: 14.5, height: 1.4)),
                if (action != null) ...[const SizedBox(height: 8), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});

  @override
  Widget build(BuildContext context) => InfoBanner(
        icon: Icons.science_rounded,
        color: AppColors.demo,
        title: tr('Demo Mode - sample data', 'Demo Mode - sample lang'),
        message: tr(
            'These readings are only examples and do not come from your '
                'pond. Connect the ESP32 sensor in Settings to see real '
                'readings.',
            'Kini nga mga basa pananglitan lang ug dili gikan sa imong '
                'fishpond. Ikonektar ang ESP32 sensor sa Settings aron makita '
                'ang tinuod nga basa.'),
      );
}

/// "Updated 10:32 AM • 2 min ago" line.
class LastUpdatedRow extends StatelessWidget {
  const LastUpdatedRow({super.key, required this.reading, this.loading = false});

  final SensorReading? reading;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final r = reading;
    final text = r == null
        ? tr('No reading yet', 'Wala pay basa')
        : '${tr('Updated', 'Gi-update')} ${Fmt.time(r.timestamp)} • '
            '${Fmt.relative(r.timestamp)}'
            '${r.isDemo ? tr(' • sample data', ' • sample lang') : ''}';
    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 16, color: AppColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: AppColors.muted, fontSize: 14)),
        ),
        if (loading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

/// Generic empty / error / loading state.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color = AppColors.teal,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 14),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4)),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message ?? tr('Getting readings…', 'Gikuha ang basa…'),
              style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

/// Text-based AquaSense logo.
class AquaSenseLogo extends StatelessWidget {
  const AquaSenseLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.aqua, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.water_drop_rounded,
                  color: Colors.white, size: size * 0.55),
              Positioned(
                bottom: size * 0.14,
                child: Icon(Icons.waves_rounded,
                    color: AppColors.deepGreen.withValues(alpha: 0.7),
                    size: size * 0.32),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Aqua', style: TextStyle(color: Colors.white)),
            TextSpan(
                text: 'Sense',
                style: TextStyle(color: AppColors.aqua.withValues(alpha: 0.95))),
          ]),
          style: TextStyle(
            fontSize: size * 0.48,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            shadows: const [Shadow(blurRadius: 12, color: Colors.black45)],
          ),
        ),
      ],
    );
  }
}

/// Translucent blurred panel for content on top of photographs.
class FrostedPanel extends StatelessWidget {
  const FrostedPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Full-screen photo background with green overlay.
class PhotoBackground extends StatelessWidget {
  const PhotoBackground({super.key, required this.image, required this.child});

  final String image;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.deepGreen.withValues(alpha: 0.35),
                AppColors.deepGreen.withValues(alpha: 0.55),
                AppColors.deepGreen.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
