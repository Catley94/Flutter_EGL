// lib/widgets/library_tab.dart (new file)
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scrollbar(
      child: SingleChildScrollView(
        primary: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Projects grid (kept)
            Text(
              'My Projects',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                const tileMinWidth = 140.0;
                const spacing = 12.0;
                final count = (constraints.maxWidth / (tileMinWidth + spacing))
                    .floor()
                    .clamp(1, 6);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    return _ProjectTile(
                      name: 'My Project ${index + 1}',
                      version: 'UE 5.${(index % 3) + 1}',
                      color: Color.lerp(
                        const Color(0xFF1F2933),
                        cs.primary,
                        (index % 5) / 5.0,
                      )!,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // Header row for filters/actions
            Row(
              children: [
                Text(
                  'Fab Library',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add Project'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Responsive grid (now non-scrollable; page scrolls instead)
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2027)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minTileWidth = 320.0;
                  const spacing = 16.0;
                  final crossAxisCount =
                      (constraints.maxWidth / (minTileWidth + spacing))
                          .floor()
                          .clamp(3, 5);
                  // final computed = (constraints.maxWidth / (minTileWidth + spacing))
                  //     .floor()
                  //     .clamp(1, 6);
                  // final crossAxisCount = math.max(3, computed);
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: 2.4,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return _FabLibraryItem(
                        title: 'Starter Content Pack ${index + 1}',
                        sizeLabel:
                            '${(1.2 + index * 0.25).toStringAsFixed(2)} GB downloaded',
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ... existing code ...
class _ProjectTile extends StatelessWidget {
  final String name;
  final String version;
  final Color color;

  const _ProjectTile({
    required this.name,
    required this.version,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Square thumbnail with version tag
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1A2027)),
                ),
                // Placeholder for a future screenshot/thumbnail
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    version,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _FabLibraryItem extends StatelessWidget {
  final String title;
  final String sizeLabel;

  const _FabLibraryItem({
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
                    onPressed: () {},
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
