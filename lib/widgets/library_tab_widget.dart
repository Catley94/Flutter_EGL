// lib/widgets/library_tab.dart (new file)
import 'package:flutter/material.dart';
import 'fab_library_item.dart';
import '../services/api_service.dart';
import '../models/unreal.dart';
import '../models/fab.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<_FabAssetsGridState> _fabKey = GlobalKey<_FabAssetsGridState>();
  late final ApiService _api;
  late Future<List<UnrealEngineInfo>> _enginesFuture;
  late Future<List<UnrealProjectInfo>> _projectsFuture;
  late Future<List<FabAsset>> _fabFuture;

  // cache of engines for deciding version on open
  List<UnrealEngineInfo> _engines = const [];
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _api = ApiService();
  }

  void _requestMoreFabItems() {
    final state = _fabKey.currentState;
    if (state == null) return;
    final total = state.widget.assets.length;
    state.increaseVisible(60, total);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final pixels = _scrollController.position.pixels;
    if (pixels >= max - 400) {
      _requestMoreFabItems();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // kick off futures after widget is mounted
    _enginesFuture = _api.listUnrealEngines().then((v) => _engines = v).then((_) => _engines).catchError((_) => _engines);
    _projectsFuture = _api.listUnrealProjects();
    _fabFuture = _api.getFabList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        primary: false,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Engine Versions grid (new)
            Text(
              'Engine Versions',
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
                return FutureBuilder<List<UnrealEngineInfo>>(
                  future: _enginesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Failed to load engines: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
                      );
                    }
                    final engines = snapshot.data ?? const <UnrealEngineInfo>[];
                    if (engines.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No engines found'),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: engines.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final e = engines[index];
                        return _ProjectTile(
                          name: e.name,
                          version: e.version.isEmpty ? 'unknown' : 'UE ${e.version}',
                          color: Color.lerp(
                            const Color(0xFF1F2933),
                            cs.primary,
                            (index % 5) / 5.0,
                          )!,
                          onTap: () {
                            // Optional: could filter projects by engine, not required now
                            debugPrint('Engine tapped: ${e.name} (${e.version})');
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
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
                return FutureBuilder<List<UnrealProjectInfo>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Failed to load projects: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
                      );
                    }
                    final projects = snapshot.data ?? const <UnrealProjectInfo>[];
                    if (projects.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No projects found'),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projects.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final p = projects[index];
                        return _ProjectTile(
                          name: p.name.isEmpty ? p.uprojectFile.split('/').last : p.name,
                          version: '',
                          color: Color.lerp(
                            const Color(0xFF1F2933),
                            cs.primary,
                            (index % 5) / 5.0,
                          )!,
                          onTap: () async {
                            if (_opening) return;
                            setState(() => _opening = true);
                            try {
                              // Choose engine: use last item from sorted list (assumed highest version)
                              String? version;
                              if (_engines.isNotEmpty) {
                                version = _engines.last.version.isNotEmpty ? _engines.last.version : null;
                              }
                              if (version == null) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No installed Unreal Engine version found')),
                                );
                              } else {
                                final result = await _api.openUnrealProject(
                                  project: p.uprojectFile.isNotEmpty ? p.uprojectFile : p.path,
                                  version: version,
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result.message.isNotEmpty ? result.message : (result.launched ? 'Launched Unreal Editor' : 'Failed to launch'))),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error opening project: $e')),
                              );
                            } finally {
                              if (mounted) setState(() => _opening = false);
                            }
                          },
                        );
                      },
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
                  return FutureBuilder<List<FabAsset>>(
                    future: _fabFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Failed to load Fab library: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
                        );
                      }
                      final assets = snapshot.data ?? const <FabAsset>[];
                      return _FabAssetsGrid(
                        key: _fabKey,
                        assets: assets,
                        crossAxisCount: crossAxisCount,
                        spacing: spacing,
                        onLoadMore: _requestMoreFabItems,
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

class _FabAssetsGrid extends StatefulWidget {
  final VoidCallback? onLoadMore;
  final List<FabAsset> assets;
  final int crossAxisCount;
  final double spacing;
  const _FabAssetsGrid({Key? key, required this.assets, required this.crossAxisCount, required this.spacing, this.onLoadMore}) : super(key: key);

  @override
  State<_FabAssetsGrid> createState() => _FabAssetsGridState();
}

class _FabAssetsGridState extends State<_FabAssetsGrid> {
  // expose a getter for parent to increase visible count
  void increaseVisible(int by, int total) {
    setState(() {
      _visibleCount = (_visibleCount + by).clamp(0, total);
    });
  }
  static const int _initialBatch = 60;
  static const int _pageSize = 60;
  int _visibleCount = _initialBatch;

  @override
  void didUpdateWidget(covariant _FabAssetsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assets.length != widget.assets.length) {
      // Reset or expand to show all if fewer than current
      _visibleCount = _initialBatch;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.assets.length;
    final show = total <= _visibleCount ? total : _visibleCount;

    // Note: The outer SingleChildScrollView handles scrolling. We can't rely on
    // inner scroll notifications. Instead, LibraryTab listens via ScrollController
    // and triggers onLoadMore; here we just render up to _visibleCount.
    return GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: widget.spacing,
          crossAxisSpacing: widget.spacing,
          childAspectRatio: 2.4,
        ),
        itemCount: show,
        itemBuilder: (context, index) {
          final a = widget.assets[index];
          return FabLibraryItem(
            title: a.title.isNotEmpty ? a.title : a.assetId,
            sizeLabel: a.shortEngineLabel.isNotEmpty ? a.shortEngineLabel : '${a.assetNamespace}/${a.assetId}',
            isCompleteProject: a.isCompleteProject,
          );
        },
      );
  }
}

// ... existing code ...
class _ProjectTile extends StatelessWidget {
  final String name;
  final String version;
  final Color color;
  final VoidCallback? onTap;

  const _ProjectTile({
    required this.name,
    required this.version,
    required this.color,
    this.onTap,
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
              // Full-surface tappable overlay with ripple
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onTap,
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

