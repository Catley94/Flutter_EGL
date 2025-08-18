import 'package:flutter/material.dart';

class FabLibraryItem extends StatelessWidget {
  final String title;
  final String sizeLabel;

  const FabLibraryItem({
    required this.title,
    required this.sizeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2027)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2933),
                border: Border.all(color: const Color(0xFF1A2027)),
              ),
              child: const Icon(Icons.image, size: 40, color: Color(0xFF9AA4AF)),
            ),
          ),
          const SizedBox(width: 16),
          // Right: title, button, size stacked vertically
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: FilledButton.icon(
                    onPressed: () {
                      print("Create Project clicked");
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Project'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sizeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}