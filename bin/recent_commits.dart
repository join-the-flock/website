import 'dart:convert';
import 'dart:io';

const commitSources = {
  'flock': 'join-the-flock/flock-patches',
  'flutter': 'flutter/flutter',
};

const commitBranches = {
  'join-the-flock/flock-patches': 'main',
  'flutter/flutter': 'master',
};

/// Local rebuilds reuse their snapshot until a refresh is explicitly requested.
/// Deployment passes [refresh] so upstream failures still fail publication.
Future<void> prepareRecentCommits({
  File? output,
  bool cachedOnly = false,
  bool refresh = false,
  Future<void> Function(File output)? fetch,
}) async {
  if (cachedOnly && refresh) {
    throw ArgumentError(
        'Use either --cached-commits or --refresh-commits, not both.');
  }
  final snapshot = output ?? File('source/data/recent-commits.json');
  if (await snapshot.exists() && !refresh) return;
  if (cachedOnly) {
    throw StateError(
      'No cached commit snapshot. Build without --cached-commits first.',
    );
  }
  await (fetch ?? (file) => fetchRecentCommits(output: file))(snapshot);
}

/// Produces one snapshot only after both upstream requests have succeeded.
Future<void> writeRecentCommits({
  required File output,
  required Future<List<dynamic>> Function(String repository) loadCommits,
  DateTime? generatedAt,
}) async {
  final snapshot = <String, dynamic>{
    'generatedAt': (generatedAt ?? DateTime.now()).toUtc().toIso8601String(),
    'sources': {
      for (final source in commitSources.entries)
        source.key: {
          'repository': source.value,
          'branch': commitBranches[source.value],
        },
    },
  };
  for (final source in commitSources.entries) {
    final commits = await loadCommits(source.value);
    if (commits.isEmpty) {
      throw FormatException('No commits returned for ${source.value}');
    }
    snapshot[source.key] = commits.map(normalizeCommit).toList();
  }
  await output.parent.create(recursive: true);
  await output.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(snapshot)}\n',
  );
}

Map<String, dynamic> normalizeCommit(dynamic value) {
  final item = value as Map<String, dynamic>;
  final commit = item['commit'] as Map<String, dynamic>;
  final author = commit['author'] as Map<String, dynamic>;
  final committer = commit['committer'] as Map<String, dynamic>;
  final account = item['author'] as Map<String, dynamic>?;
  final sha = item['sha'] as String;
  final message = (commit['message'] as String).split('\n').first.trim();
  final url = Uri.parse(item['html_url'] as String);
  if (sha.isEmpty ||
      message.isEmpty ||
      url.scheme != 'https' ||
      url.host != 'github.com') {
    throw const FormatException('Invalid commit metadata');
  }
  return {
    'sha': sha,
    'message': message,
    'url': url.toString(),
    'authorName': author['name'] as String,
    'authorLogin': account?['login'],
    'avatarUrl': account?['avatar_url'],
    'authoredAt':
        DateTime.parse(author['date'] as String).toUtc().toIso8601String(),
    'committedAt':
        DateTime.parse(committer['date'] as String).toUtc().toIso8601String(),
  };
}

Future<void> fetchRecentCommits({File? output}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  final token = Platform.environment['GITHUB_TOKEN'];
  try {
    await writeRecentCommits(
      output: output ?? File('source/data/recent-commits.json'),
      loadCommits: (repository) async {
        final uri = Uri.https('api.github.com', '/repos/$repository/commits', {
          'sha': commitBranches[repository],
          'per_page': '20',
        });
        return (() async {
          final request = await client.getUrl(uri);
          request.headers.set(
            HttpHeaders.acceptHeader,
            'application/vnd.github+json',
          );
          request.headers.set(
            HttpHeaders.userAgentHeader,
            'Flock-website-build',
          );
          request.headers.set('X-GitHub-Api-Version', '2026-03-10');
          if (token != null && token.isNotEmpty) {
            request.headers.set(
              HttpHeaders.authorizationHeader,
              'Bearer $token',
            );
          }
          final response = await request.close();
          final body = await response.transform(utf8.decoder).join();
          if (response.statusCode != HttpStatus.ok) {
            throw HttpException(
              'GitHub returned HTTP ${response.statusCode} for $repository',
              uri: uri,
            );
          }
          return jsonDecode(body) as List<dynamic>;
        })()
            .timeout(const Duration(seconds: 30));
      },
    );
  } finally {
    client.close(force: true);
  }
}

Future<void> main() async {
  await fetchRecentCommits();
  stdout.writeln('Updated source/data/recent-commits.json');
}
