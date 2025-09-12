class FabLibraryResponse {
  final List<FabAsset> results;
  FabLibraryResponse({required this.results});

  factory FabLibraryResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List<dynamic>? ?? []);
    return FabLibraryResponse(
      results: list.map((e) => FabAsset.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class FabImageRef {
  final String url;
  final String? type;
  final int? width;
  final int? height;

  FabImageRef({required this.url, this.type, this.width, this.height});

  factory FabImageRef.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    return FabImageRef(
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString(),
      width: parseInt(json['width']),
      height: parseInt(json['height']),
    );
  }
}

class FabProjectVersion {
  final String artifactId;
  final List<String> engineVersions; // e.g., ["UE_5.3", "UE_5.4"]
  final List<String> targetPlatforms;

  FabProjectVersion({required this.artifactId, required this.engineVersions, required this.targetPlatforms});

  factory FabProjectVersion.fromJson(Map<String, dynamic> json) {
    return FabProjectVersion(
      artifactId: json['artifactId']?.toString() ?? '',
      engineVersions: (json['engineVersions'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      targetPlatforms: (json['targetPlatforms'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class FabAsset {
  final String title;
  final String description;
  final String assetId;
  final String assetNamespace;
  final String source; // usually "fab"
  final String? url; // listing url
  final String distributionMethod; // e.g., COMPLETE_PROJECT, ASSET_PACK
  final List<FabImageRef> images;
  final List<FabProjectVersion> projectVersions;

  FabAsset({
    required this.title,
    required this.description,
    required this.assetId,
    required this.assetNamespace,
    required this.source,
    required this.url,
    required this.distributionMethod,
    required this.images,
    required this.projectVersions,
  });

  factory FabAsset.fromJson(Map<String, dynamic> json) {
    return FabAsset(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      assetId: json['assetId']?.toString() ?? '',
      assetNamespace: json['assetNamespace']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      url: json['url']?.toString(),
      distributionMethod: json['distributionMethod']?.toString() ?? '',
      images: (json['images'] as List<dynamic>? ?? []).map((e) => FabImageRef.fromJson(e as Map<String, dynamic>)).toList(),
      projectVersions: (json['projectVersions'] as List<dynamic>? ?? []).map((e) => FabProjectVersion.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  bool get isCompleteProject => distributionMethod == 'COMPLETE_PROJECT';

  String get shortEngineLabel {
    // Construct a compact label like "UE: 5.6, 5.5" from engineVersions prefixes
    final engines = <String>{};
    for (final v in projectVersions) {
      for (final ev in v.engineVersions) {
        // ev values look like UE_5.6, UE_4.27, etc.
        final parts = ev.split('_');
        if (parts.length > 1) engines.add(parts[1]);
      }
    }
    if (engines.isEmpty) return '';
    final sorted = engines.toList()..sort();
    // Keep at most 4 entries to avoid overflow
    final shown = sorted.take(4).join(', ');
    return 'UE: $shown${sorted.length > 4 ? '…' : ''}';
  }
}
