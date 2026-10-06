import 'package:flutter/material.dart';

Widget appLogo({double size = 60}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF5B5FEF),
          Color(0xFF8B7CFF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(size * .28),
    ),
    child: Icon(
      Icons.storefront_rounded,
      size: size * .48,
      color: Colors.white,
    ),
  );
}

Widget imagePlaceholder(BuildContext context) {
  return Container(
    color: Theme.of(context)
        .colorScheme
        .primary
        .withOpacity(.07),
    child: Center(
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

Widget emptyState(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle,
) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}