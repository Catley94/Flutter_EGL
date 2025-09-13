import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/unreal.dart';
import '../models/fab.dart';

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? defaultBaseUrl;

  static const String defaultBaseUrl = 'http://127.0.0.1:8080';

  final String baseUrl;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse(baseUrl).replace(path: path, queryParameters: query);
  }

  Future<List<UnrealEngineInfo>> listUnrealEngines({String? baseDir}) async {
    final uri = _uri('/list-unreal-engines', baseDir != null ? {'base': baseDir} : null);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch engines: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final engines = (data['engines'] as List<dynamic>? ?? [])
        .map((e) => UnrealEngineInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    return engines;
  }

  Future<OpenEngineResult> openUnrealEngine({required String version}) async {
    final uri = _uri('/open-unreal-engine', {'version': version});
    final res = await http.get(uri);
    final body = res.body;
    if (res.statusCode != 200) {
      // Try to parse message from JSON; otherwise surface body
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final msg = data['message']?.toString() ?? body;
        throw Exception('Failed to open Unreal Engine: ${res.statusCode} $msg');
      } catch (_) {
        throw Exception('Failed to open Unreal Engine: ${res.statusCode} $body');
      }
    }
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return OpenEngineResult.fromJson(data);
    } catch (_) {
      // Backend might return plain text; treat 200 as success with message
      return OpenEngineResult(launched: true, message: body.isNotEmpty ? body : 'Launched Unreal Engine');
    }
  }

  Future<List<UnrealProjectInfo>> listUnrealProjects({String? baseDir}) async {
    final uri = _uri('/list-unreal-projects', baseDir != null ? {'base': baseDir} : null);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch projects: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final projects = (data['projects'] as List<dynamic>? ?? [])
        .map((e) => UnrealProjectInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    return projects;
  }

  Future<List<FabAsset>> getFabList() async {
    final uri = _uri('/get-fab-list');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch Fab library: ${res.statusCode} ${res.body}');
    }
    // The backend returns either the full JSON object or sometimes a string body on edge cases.
    final dynamic decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      final lib = FabLibraryResponse.fromJson(decoded);
      return lib.results;
    } else {
      // Unexpected format; return empty list but not crash UI
      return <FabAsset>[];
    }
  }

  Future<OpenProjectResult> openUnrealProject({required String project, required String version, String? engineBase, String? projectsBase}) async {
    final query = <String, String>{
      'project': project,
      'version': version,
      if (engineBase != null) 'engine_base': engineBase,
      if (projectsBase != null) 'projects_base': projectsBase,
    };
    final uri = _uri('/open-unreal-project', query);
    print("Query: $query");
    final res = await http.get(uri);
    final body = res.body;
    if (res.statusCode != 200) {
      // Backend may return JSON with message; surface it
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final msg = data['message']?.toString() ?? body;
        throw Exception('Failed to open project: ${res.statusCode} $msg');
      } catch (_) {
        throw Exception('Failed to open project: ${res.statusCode} $body');
      }
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    return OpenProjectResult.fromJson(data);
  }

  Future<ImportAssetResult> importAsset({required String assetName, required String project, String? targetSubdir, bool overwrite = false}) async {
    final uri = _uri('/import-asset');
    final payload = <String, dynamic>{
      'asset_name': assetName,
      'project': project,
      if (targetSubdir != null && targetSubdir.isNotEmpty) 'target_subdir': targetSubdir,
      if (overwrite) 'overwrite': true,
    };
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final body = res.body;
    if (res.statusCode != 200) {
      // Try to parse error message from JSON; otherwise surface plain text
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final msg = data['message']?.toString() ?? body;
        throw Exception('Import failed: ${res.statusCode} $msg');
      } catch (_) {
        throw Exception('Import failed: ${res.statusCode} $body');
      }
    }
    // Try parse JSON; otherwise treat as success with message
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return ImportAssetResult.fromJson(data);
    } catch (_) {
      return ImportAssetResult(success: true, message: body.isNotEmpty ? body : 'Import started');
    }
  }
}

class OpenProjectResult {
  final bool launched;
  final String? engineName;
  final String? engineVersion;
  final String? editorPath;
  final String project;
  final String message;

  OpenProjectResult({
    required this.launched,
    required this.engineName,
    required this.engineVersion,
    required this.editorPath,
    required this.project,
    required this.message,
  });

  factory OpenProjectResult.fromJson(Map<String, dynamic> json) {
    return OpenProjectResult(
      launched: json['launched'] as bool? ?? false,
      engineName: json['engine_name'] as String?,
      engineVersion: json['engine_version'] as String?,
      editorPath: json['editor_path'] as String?,
      project: json['project'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

class OpenEngineResult {
  final bool launched;
  final String message;

  OpenEngineResult({required this.launched, required this.message});

  factory OpenEngineResult.fromJson(Map<String, dynamic> json) {
    return OpenEngineResult(
      launched: json['launched'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

class ImportAssetResult {
  final bool success;
  final String message;
  final String? project;
  final String? assetName;

  ImportAssetResult({required this.success, required this.message, this.project, this.assetName});

  factory ImportAssetResult.fromJson(Map<String, dynamic> json) {
    // Backend may return keys like { success, message, project, asset_name }
    return ImportAssetResult(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      project: json['project'] as String?,
      assetName: (json['asset_name'] ?? json['assetName']) as String?,
    );
  }
}

class CreateProjectResult {
  final bool ok;
  final String message;
  final String? command;
  final String? projectPath;

  CreateProjectResult({required this.ok, required this.message, this.command, this.projectPath});

  factory CreateProjectResult.fromJson(Map<String, dynamic> json) {
    return CreateProjectResult(
      ok: json['ok'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      command: json['command'] as String?,
      projectPath: (json['project_path'] ?? json['projectPath']) as String?,
    );
  }
}

extension CreateUnrealProjectApi on ApiService {
  Future<CreateProjectResult> createUnrealProject({
    String? enginePath,
    String? templateProject,
    String? assetName,
    required String outputDir,
    required String projectName,
    String projectType = 'bp',
    bool dryRun = false,
  }) async {
    final uri = _uri('/create-unreal-project');
    final payload = <String, dynamic>{
      'engine_path': enginePath,
      'template_project': templateProject,
      'asset_name': assetName,
      'output_dir': outputDir,
      'project_name': projectName,
      'project_type': projectType,
      'dry_run': dryRun,
    }..removeWhere((key, value) => value == null);

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final body = res.body;
    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final msg = data['message']?.toString() ?? body;
        throw Exception('Create project failed: ${res.statusCode} $msg');
      } catch (_) {
        throw Exception('Create project failed: ${res.statusCode} $body');
      }
    }
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return CreateProjectResult.fromJson(data);
    } catch (_) {
      return CreateProjectResult(ok: true, message: body.isNotEmpty ? body : 'OK', command: null, projectPath: null);
    }
  }
}
