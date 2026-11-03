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
  group('build snapshot cache', () {
    late Directory directory;
    late File output;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('flock-cache-test-');
      output = File('${directory.path}/recent-commits.json');
    });
    tearDown(() => directory.delete(recursive: true));

    test('repeated builds reuse even an old snapshot without fetching',
        () async {
      await output.writeAsString('{"generatedAt":"2020-01-01T00:00:00Z"}');
      var requests = 0;
      for (var build = 0; build < 10; build++) {
        await prepareRecentCommits(
          output: output,
          fetch: (_) async {
            requests++;
          },
        );
      }
      expect(requests, 0);
      expect(await output.readAsString(), contains('2020-01-01'));
    });

    test('first build fetches once and following saves use that snapshot',
        () async {
      var requests = 0;
      for (var build = 0; build < 3; build++) {
        await prepareRecentCommits(
          output: output,
          fetch: (file) async {
            requests++;
            await writeRecentCommits(
                output: file, loadCommits: (_) async => [fixture()]);
          },
        );
      }
      expect(requests, 1);
      expect(jsonDecode(await output.readAsString())['flock'], hasLength(1));
    });

    test('explicit refresh fetches even when a snapshot exists', () async {
      await output.writeAsString('old snapshot');
      var requests = 0;
      await prepareRecentCommits(
        output: output,
        refresh: true,
        fetch: (file) async {
          requests++;
          await writeRecentCommits(
              output: file, loadCommits: (_) async => [fixture()]);
        },
      );
      expect(requests, 1);
      expect(jsonDecode(await output.readAsString())['flutter'], hasLength(1));
    });

    test('a failed refresh fails but subsequent local builds do not retry',
        () async {
      await output.writeAsString('previous snapshot');
      var requests = 0;
      Future<void> fail(File file) async {
        requests++;
        await writeRecentCommits(
          output: file,
          loadCommits: (_) async => throw const HttpException('Rate limited'),
        );
      }

      await expectLater(
        prepareRecentCommits(output: output, refresh: true, fetch: fail),
        throwsA(isA<HttpException>()),
      );
      await prepareRecentCommits(output: output, fetch: fail);
      expect(requests, 1);
      expect(await output.readAsString(), 'previous snapshot');
    });

    test('cached-only build never fetches when its snapshot is missing',
        () async {
      var requests = 0;
      await expectLater(
        prepareRecentCommits(
          output: output,
          cachedOnly: true,
          fetch: (_) async {
            requests++;
          },
        ),
        throwsStateError,
      );
      expect(requests, 0);
    });

    test('conflicting cache flags fail before fetching', () async {
      await expectLater(
        prepareRecentCommits(output: output, cachedOnly: true, refresh: true),
        throwsArgumentError,
      );
    });
  });

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
