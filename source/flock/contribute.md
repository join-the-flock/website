---
title: Contribute to Flock
description: How to get setup for, and contribute to Flock
code_examples: true
---
# Contribute
Flock is defined by a series of patch files, but nobody can write a patch file by hand. Instead,
the way you contribute to Flock is by checking out the latest version of Flock, making your
changes to Flock, and then you generate your patch file based on your local changes.

## Setup Nest, Patches, and Flock
Nest has the tools you'll use to work on Flock, and it's where you'll hatch your version of Flock.

Install a standalone Dart SDK before running the Nest patch tools.

Get set up:

```bash
# Clone the Nest repo and work from there.
git clone https://github.com/join-the-flock/nest.git
cd nest

# Resolve the patch tools' Dart dependencies.
(cd nest_patches && dart pub get --enforce-lockfile)

# Clone the current Flock patches into `nest/patches/`.
git clone --branch main https://github.com/join-the-flock/flock-patches.git patches

# Check out the upstream Flutter channel you'll build on.
git clone --branch master https://github.com/flutter/flutter.git flock

# Create Flock, locally, by applying patches on top of Flutter.
dart run nest_patches/bin/git_import_patches.dart -p patches --channel master -3
```

After this setup process, ensure the following directories exist:

    nest/
      flock/   # This is where you make your changes
      patches/ # This is where you'll save your patch file

This example uses Flutter `master` with `.patches-master` from the patch
repository's `main` branch. To work on beta or stable, check out that Flutter
branch and use the matching `--channel` for both import and export.

For engine work, follow Flutter's [engine development setup](https://github.com/flutter/flutter/blob/master/docs/engine/contributing/Setting-up-the-Engine-development-environment.md)
for tools and dependency synchronization, using your `nest/flock/` checkout.

## Prepare for development
When working on Flock you need to work on a development branch:

```bash
cd flock
git checkout -b my-branch
```

Creating a new branch is not optional. It's required. The problem is how Flutter tracks
engine versions.

Flutter treats the `master`, `beta`, and `stable` branches as special. Every engine build for
those branches has a hash that must match the exact files in your Flutter SDK. If they don't
match, Flutter prevents you from downloading the engine, which keeps you from running any
Flutter commands at all. This is a problem for Flock, because Flock always adds changes to
Flutter, so the engine hash will never match on those branches.

This hash match issue goes away if you're on some other branch. Any other branch is treated by
Flutter as a "development branch". In that case, Flutter checks whether you branched off of
`master`, `beta`, or `stable`, and then uses the most recent engine binary from that upstream
branch. Flutter no longer cares that your Flock engine hash doesn't match the one that Flutter
downloads.

## Configure an app to use your local Flock
Very simple changes and fixes can be validated by adding tests to Flock. But most changes deserve
a human verification, within a standalone app.

To verify your local version of Flock within a Flutter app, register your local Flock version
with FVM:

```bash
# This is where FVM expects to find local Flutter forks.
mkdir -p ~/fvm/versions

# Instead of moving our entire Flock project into `fvm/versions`,
# we'll just link from there to where it really lives.
ln -s \
    /path/to/nest/flock \
    ~/fvm/versions/custom_flock_dev
```

With the changes above, you can now use your local Flock version in any Flutter app, with FVM.

```bash
cd /path/to/my/app/

# Use your local Flock version to build and run your Flutter app.
fvm use custom_flock_dev --skip-setup --skip-pub-get
```

## Create your patch
Once you've made the changes to Flock that you want to contribute, you need to turn
those changes into a patch file.

### Commit your changes to Flock
Commit all of your changes, in a single commit, to your local development version of Flock.

Make sure you know what changed:

    # In nest/flock/
    git status

Stage your changes:

    git add -A

Commit your changes with a well crafted commit message. The first line of your commit message
will become the name of your patch file, so make it descriptive, but short, and don't use any
special characters. Then, after the first line, add relevant information to capture the intent
of your change, any important information about what it impacts, what upstream Flutter ticket
it implements, or if this is intended as a temporary change, make that clear as well, along
with how/when we know it should be removed.

Example commit message when changing Flutter's version reporting:

```bash
git commit -F - <<'EOF'
Report Flock version with Flutter version

Running `fvm flutter --version` now reports Flock-relevant info.

This patch only impacts the Flutter tool. It alters the Flutter tool's version reporting behavior.

Example output:
Flock (Flutter 3.50.0-1.0.pre-364) • channel master • branch 31134_feature_add-min-lines-to-text-widget • https://github.com/join-the-flock/flock.git
Flock framework • revision 43cb4babf2 (1 year, 5 months ago) • 2025-05-25 14:48:07 -0700
Flutter upstream • revision 0cfd273f47 (12 hours ago) • 2026-11-03 02:51:58 +0000
Engine • hash 4aa1c0903151d534fae62656cc7b1fe9b60dae0e (revision 0cfd273f47) (12 hours ago) • 2026-11-03 02:51:58.000Z
Tools • Dart 3.15.0 (build 3.15.0-101.0.dev) • DevTools 2.62.0-dev.0
EOF
```

### Export your patch
Now that you've committed all of your changes to Flock, within a single commit, you can export
your changes to a patch file.

```bash
# From nest/flock/
dart run ../nest_patches/bin/git_export_patches.dart --flutter . --patches-dir ../patches --channel master

# OR from nest/
dart run nest_patches/bin/git_export_patches.dart --patches-dir patches --channel master
```

The patch export process doesn't just turn your change into a patch. It re-exports all previously
existing Flock patches, too. Don't be surprised if this process alters some pre-existing patch
files. That can happen.

### Put up your patch for review
Patches live in their own repository called `flock-patches`. You've already used those patches,
but you may not have known they came from their own repository.

After exporting your patches, navigate to your patches directory and notice that you've added
a patch file, and that you've possibly altered existing patch files.

Example git output:

```bash
patches % git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   .patches-master
	modified:   add_slim_gclients.patch
	modified:   added_gclient_files_to_gitignore_to_support_flock_and_other_flutter.patch
	modified:   create-patch-pr.patch
	modified:   fix_ios_builds.patch

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	report_flock_version_with_flutter_version.patch
```

The `.patches-master` file lists the order in which master patches are applied.
Since you're adding a new patch file, you should expect this manifest to have changed.

Your new patch file should appear under "Untracked files", because it's new.

The other modifications are likely formatting changes that happened when the original patches
were applied. It's worth a look to make sure nothing bad happened in those patch files. If they
look OK, then go ahead and commit everything.

```bash
# From nest/patches/

# Add a remote that points to your own fork of flock-patches, so you
# push to GitHub and open a pull request.
git remote add my-patches [insert your GitHub repo URL]

# Checkout a new branch locally
git checkout -b infra_report-flock-version-info

# Stage all the changes in nest/patches/
git add -A

# Commit your patch file with a good message
git commit -m "[Infra] - Report Flock version info when running 'fvm flutter --version'"

# Push to your fork of the patch repo so you can put up a pull request
git push my-patches infra_report-flock-version-info
```

### Update your patch based on review
Reviewers might request that you make changes to your patch. Don't try to alter the patch
file by hand. Instead, go back to your local Flock distribution and make changes there.

Once you've adjusted what's requested, amend your original commit with your new changes,
so that all of your changes remain in a single commit.

```bash
git commit --amend
```

Then, re-export your patch files, add a new commit to your patches branch, and then push
your updates to GitHub for further review.
