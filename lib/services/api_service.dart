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
