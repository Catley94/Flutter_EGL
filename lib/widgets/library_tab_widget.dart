// lib/widgets/library_tab.dart (new file)
import 'package:flutter/material.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Projects grid (new)
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
                  // Make cells a bit taller to fit the square + label
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
          // Header row for filters/actions (placeholder)
          Row(
            children: [
              Text(
                'Your Unreal Engine Library',
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
          // Content area (placeholder list)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2027)),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text('Project ${index + 1}'),
                    subtitle: const Text('Unreal Engine 5.x'),
                    trailing: FilledButton(
                      onPressed: () {},
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
