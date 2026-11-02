import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../bin/recent_commits.dart';

Map<String, dynamic> fixture({bool linkedAuthor = true}) => {
  'sha': 'abc123',
  'html_url': 'https://github.com/flutter/flutter/commit/abc123',
  'author': linkedAuthor
      ? {
          'login': 'contributor',
          'avatar_url': 'https://avatars.githubusercontent.com/u/1',
        }
      : null,
  'commit': {
    'message':
        'A commit subject\n\nA longer body that should not appear on the card.',
    'author': {'name': 'Contributor Name', 'date': '2026-11-01T12:00:00Z'},
    'committer': {'date': '2026-11-01T13:00:00Z'},
  },
};

void main() {
  test('keeps the subject, identity, URL and distinct author/commit dates', () {
    final commit = normalizeCommit(fixture());
    expect(commit['message'], 'A commit subject');
    expect(commit['authorLogin'], 'contributor');
    expect(commit['authoredAt'], '2026-11-01T12:00:00.000Z');
    expect(commit['committedAt'], '2026-11-01T13:00:00.000Z');
    expect(commit['url'], 'https://github.com/flutter/flutter/commit/abc123');
  });

  test('preserves git author when no GitHub account matches', () {
    final commit = normalizeCommit(fixture(linkedAuthor: false));
    expect(commit['authorName'], 'Contributor Name');
    expect(commit['authorLogin'], isNull);
    expect(commit['avatarUrl'], isNull);
  });

  test('writes both feeds and provenance in one snapshot', () async {
    final directory = await Directory.systemTemp.createTemp('flock-feed-test-');
    addTearDown(() => directory.delete(recursive: true));
    final output = File('${directory.path}/data/recent-commits.json');
    final requested = <String>[];
    await writeRecentCommits(
      output: output,
      generatedAt: DateTime.utc(2026, 11, 1),
      loadCommits: (repository) async {
        requested.add(repository);
        return [fixture()];
      },
    );
    expect(requested, ['join-the-flock/flock-patches', 'flutter/flutter']);
    final data = jsonDecode(await output.readAsString());
    expect(data['flock'], hasLength(1));
    expect(data['flutter'], hasLength(1));
    expect(data['sources']['flock']['branch'], 'master');
  });

  test('does not replace the previous snapshot if either feed fails', () async {
    final directory = await Directory.systemTemp.createTemp('flock-feed-test-');
    addTearDown(() => directory.delete(recursive: true));
    final output = File('${directory.path}/recent-commits.json');
    await output.writeAsString('previous snapshot');
    await expectLater(
      writeRecentCommits(
        output: output,
        loadCommits: (repository) async {
          if (repository == 'flutter/flutter') {
            throw const HttpException('Upstream unavailable');
          }
          return [fixture()];
        },
      ),
      throwsA(isA<HttpException>()),
    );
    expect(await output.readAsString(), 'previous snapshot');
  });

  test('rejects an empty upstream feed', () async {
    final directory = await Directory.systemTemp.createTemp('flock-feed-test-');
    addTearDown(() => directory.delete(recursive: true));
    await expectLater(
      writeRecentCommits(
        output: File('${directory.path}/recent-commits.json'),
        loadCommits: (_) async => [],
      ),
      throwsFormatException,
    );
  });
}
