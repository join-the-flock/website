---
title: Nest Patches
section_title: Patches
description: How Nest represents, imports, and exports the patches that make up a Flutter fork.
code_examples: true
---

Nest, and its forks, depend on the use of patch files.

A patch file is a text file that contains the same kind of information that exists
in a single Git commit.

Nest defines a fork by patch files because Nest assumes that every fork wants to
stay up to date with Flutter on a continuous basis. It's much easier to rebase
a fork on top of Flutter each day, using patch files, than trying to wrestle with
Git history, directly.

This page describes what a patch file is, how they're applied on top of Flutter,
and how you can generate more patch files, to contribute to a Flutter fork.

## Tooling
To work with patch files, patch manifests, importing, and exporting, use the
`nest_patches` Dart package, which sits in the `nest` repository.

The `nest_patches` package implements reading and writing of patch files.

## Patch Protocol

A `.patch` file uses Git's mail patch format. It contains one or more consecutive
mail messages. Each message describes one commit and includes its metadata,
optional description, and one or more file diffs.

### Message Structure

This is a complete patch that changes one line in `README.md`:

```text
From 0000000000000000000000000000000000000000 Mon Sep 17 00:00:00 2001
From: Nest Example <contributor@example.invalid>
Date: Wed, 4 Nov 2026 12:00:00 +0000
Subject: Update README

Describe the fork.

diff --git a/README.md b/README.md
index 4098c542aab2cc3ac848c838784438ec2ba5eac9..d2eadd095fa4eb9ab69c5eb80a0901a8e5de9e7d 100644
--- a/README.md
+++ b/README.md
@@ -1 +1 @@
-Old text.
+New text.
```

- **`From <commit-id> ...`** starts a message. It is an envelope marker, separate
  from the author header. Nest-generated files use 40 zeroes for this ID to keep
  patches stable across rebases; ordinary Git patches can contain a real commit ID.
- **`From:`** identifies the author by name and email.
- **`Date:`** records the author's timestamp, including the timezone.
- **`Subject:`** supplies the commit's subject.
- A **blank line** ends the headers. An optional commit description follows,
  separated from the file diffs by a blank line.

A standard Git patch can also include a `---` separator and diff statistics before
the file diffs. They are not required in Nest's generated files. To represent
another commit in the same file, append another complete message beginning with
its own `From <commit-id> ...` envelope.

### File Diffs

Each file diff begins with `diff --git a/<old-path> b/<new-path>`.

- **`index <old-blob>..<new-blob> [mode]`** identifies file contents, not commits.
- **`---` and `+++`** identify the old and new file paths. `/dev/null` represents
  a missing side when adding or deleting a file.
- **`@@ -<start>,<count> +<start>,<count> @@`** gives the old and new line ranges
  for a text hunk. A count of one can be omitted.
- Within a hunk, a leading **space** marks unchanged context, **`-`** removes a
  line, and **`+`** adds a line.

Standard Git headers represent new files, deleted files, renames, and mode
changes. Modes include `100644` for regular files, `100755` for executable files,
and `120000` for symbolic links. Binary changes use Git's `GIT binary patch`
payload. Preserve diff contents and line endings, including binary payloads.

### Whole-File Replacements

Nest adds one extended diff header: **`replace file mode <mode>`**. It means
“use this complete file,” regardless of the file's current upstream contents.

Inside a mail message, a replacement diff looks like this:

```text
diff --git a/README.md b/README.md
replace file mode 100644
index 0000000000000000000000000000000000000000..3d0798163f65baa27af3fbe50f89c4b05b5081fb
--- /dev/null
+++ b/README.md
@@ -0,0 +1 @@
+Entire replacement.
```

The replacement format has these rules:

- Include exactly one `replace file mode` header, before the payload. The mode
  must be `100644`, `100755`, or `120000`.
- If an `index` header is present, its old blob ID must contain only zeroes.
  The replacement must not depend on the previous file's contents.
- A nonempty text replacement uses `--- /dev/null` and one complete addition
  hunk: `@@ -0,0 +1,N @@`, followed by exactly `N` added lines. It has no removed
  or context lines. An empty file needs no text hunk; binary replacements use a
  Git binary patch containing the complete replacement image.
- Do not combine this header with separate add, delete, rename, copy, or
  mode-change headers. Do not include another diff for the same destination in
  the same message.
- Replacement paths are literal repository-relative paths using forward slashes.
  Absolute paths, empty segments, `.`, `..`, `.git` segments, backslashes,
  colons, control characters, and leading or trailing whitespace are invalid.

A message can mix ordinary diffs and replacement diffs for different files.
A replacement overwrites upstream edits to that file rather than merging them.

### Reserved Metadata

`Patch-Dir:`, `Patch-Filename:`, and `Patch-Replace-File:` are Nest's internal
commit-message metadata. They are omitted from generated patch files. In
particular, `Patch-Replace-File:` is not an on-disk replacement header: a patch
file must use `replace file mode` instead.

## Patch Manifests

A Flutter fork is defined by a series of patch files that are played back on
top of Flutter. The list of patches that constitute a Flutter fork are defined
in a text file called a patch manifest.

A manifest lists one patch filename per line, in the order to apply them.
Patch files live in the same directory as the patch manifest file.

For example, a patch collection can contain three channel manifests and their
patch files:

```text
patches/
├── .patches-master
├── .patches-beta
├── .patches-stable
├── fix_build.patch
├── add_feature.patch
└── add_feature_2026-09-08.patch
```

The `.patches-stable` file might contain:

```text
fix_build.patch
add_feature.patch
```

This applies `fix_build.patch` first, then `add_feature.patch`. A patch file is
only applied when it is listed in the selected manifest.

### Channels

Use `.patches-master`, `.patches-beta`, or `.patches-stable` to select patches for
each Flutter channel. Legacy collections use a single `.patches` manifest.

Channels can share the same patch file or select different adaptations.

### Variants

A baseline uses `<name>.patch`. A compatibility adaptation uses
`<name>_YYYY-MM-DD.patch`, dated with the UTC date of the upstream change that
required it. Each manifest selects at most one variant of a given change.

In the example above, `.patches-master` could list
`add_feature_2026-09-08.patch` instead of `add_feature.patch`, while beta and stable
continue using the baseline. The manifest selects the variant; the date does not
automatically determine which channel uses it.

## Importing

Check out the upstream Flutter revision you want to build on, then import the
selected collection:

```bash
dart run nest_patches/bin/git_import_patches.dart \
  --flutter /path/to/flutter \
  --patches-dir /path/to/patches \
  --channel stable \
  -3
```

Import applies the patches in manifest order as Git commits. It records the
starting revision at `refs/patches/upstream-head` so export can distinguish your
patches from upstream history. `-3` enables Git's three-way merging.

Use `--manifest .patches-stable` instead of `--channel stable` to select a manifest
directly. Collections with channel manifests require an explicit selection;
legacy `.patches` collections do not.

If `git am` stops on a conflict, resolve it, stage the affected files, and run
`git -C /path/to/flutter am --continue`. Use `git -C /path/to/flutter am --abort`
to cancel that import.

## Exporting

Commit your changes in the fork, then check what an export would change:

```bash
dart run nest_patches/bin/git_export_patches.dart \
  --flutter /path/to/flutter \
  --patches-dir /path/to/patches \
  --channel stable \
  --dry-run
```

Remove `--dry-run` to write the patch files and selected manifest. A dry run writes
nothing and exits with a nonzero status when changes would be needed.

By default, export selects commits after the upstream revision recorded during
import. Without that reference, it falls back to the nearest reachable Git tag.
Pass a Git revision or range as the positional argument to choose a different
starting point.

To mark a committed file as a whole-file replacement, add this trailer to its
commit message. Repeat it for multiple files:

```text
Patch-Replace-File: path/to/file
```

Export turns the trailer into the `replace file mode` diff format described above.

Export updates only the selected manifest. It preserves other manifests and
unlisted files, and removes an old patch file only when no manifest still uses it.

- Use a **dated adaptation** when a shared patch needs different implementations
  for different channels. Set its commit's `Patch-Filename:` line to the new filename.
- Use **`--update-shared`** to deliberately change a shared file for every channel
  that selects it. Export otherwise refuses to overwrite changed shared patches.
- Use **`--grep "text"`** to export matching patch files while retaining the other
  selected patches and their order. If a file contains multiple commits, export
  includes the whole file.

Review the exported diff and validate every affected channel before committing
the patch repository changes.
