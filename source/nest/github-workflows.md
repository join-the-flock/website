---
title: Nest GitHub Workflows
section_title: GitHub Workflows
description: Automate Flutter fork maintenance with Nest's daily rebasing, custom engine builds, and tooling tests.
---

Maintaining a Flutter fork means repeatedly applying patches to upstream changes,
checking that the result works, and publishing an SDK that other developers can
use. Engine changes also require building and distributing native binaries.

Nest's GitHub Actions workflows automate these jobs. They run in your own cloned Nest
repository, using separate repositories for your [patch files](/nest/patches/)
and your published fork (e.g. Flock).

## Daily Rebase and Publication

A daily rebase workflow rebuilds your fork from the latest upstream Flutter
history and your patch collection, validates the result, and publishes it to
your SDK repository.

Flock's [`daily-flock-rebase` workflow](https://github.com/join-the-flock/nest/blob/main/.github/workflows/daily-flock-rebase.yaml)
is a working example of this process. It publishes Flock's `master`, `beta`, and
`stable` branches daily at 12:00 UTC, or on demand. In your Nest clone, rename and
adapt this workflow for your repositories, channels, and validation checks.

**Create your workflow**

1. In your Nest clone, rename `.github/workflows/daily-flock-rebase.yaml` to
   `.github/workflows/daily-rebase.yaml`, or a filename that identifies your fork.
   Edit this renamed file to create your version of the workflow. Keep Nest's
   local actions and tools alongside it; the workflow calls them through local
   paths.
2. Change the workflow's `name` to identify your fork. Rename the job and step
   labels as needed, and give its concurrency group a distinct prefix while
   retaining the channel suffix. Keep `cancel-in-progress: false` to prevent
   overlapping publications of the same channel.
3. Choose the channels in `matrix.config` and set your daily schedule. The example
   uses `[master, beta, stable]` and keeps `fail-fast: false` so a failed channel
   does not cancel the others. Keep `workflow_dispatch` to allow manual runs.
4. Point the assembly step at your patch repository and its branch using
   `patches_repo` and `patches_ref`. For each channel, select the matching
   `.patches-<channel>` through `patches_manifest`. The example uses patch
   repository branch `main` for every channel.
5. Replace the `join-the-flock/flock-demo` checkout with your own validation app
   and choose its matching branch or revision. Adapt the validation command and
   checks to your fork, using the assembled SDK rather than an already-published
   SDK. Update the report path and uploaded artifact name if you rename them.
6. Set the final publishing step's `destination_repo` to your SDK repository and
   `destination_branch` to the channel you intend to publish. Keep this step
   after successful validation.

Use Nest's reusable `assemble-fork` and `publish-fork` actions in your workflow.
Set `fork_path` consistently on assembly, engine build, and publication steps;
set `patches_path` on assembly. Supply `git_user_name` and `git_user_email` for
assembly commits. Flock's example explicitly uses `flock/` and `patches/`. The SDK checkout path
is required on each action that takes `fork_path`; it has no default. Install standalone Dart
at workflow level before invoking assembly so analyzer annotations work.

**Configure repositories and credentials**

If you retain the example's variable names, add these in your Nest repository's
**Settings → Secrets and variables → Actions**:

- Repository variable **`FLOCK_REPO`**: your destination SDK repository, in
  `owner/repository` form.
- Repository variable **`FLOCK_PATCHES_REPO`**: your patch repository, in the same
  format.
- Repository secret **`REPO_WORKFLOW_PAT`**: an access token that can read your
  source repositories and write to your destination SDK repository.

You can rename these for your fork, but update every reference in your workflow.
Pass the token to the assembly step as well as configuring the destination:
assembly establishes the Git credentials used for publication.

Publication **force-pushes the destination branches**, replacing their history.
Store your changes in the patch repository rather than making unique commits
directly on the published SDK branches.

**Run your workflow**

Commit your workflow to your Nest repository's default branch. In **Actions**,
select the name you assigned, choose **Run workflow**, and select the branch
containing your configured workflow. GitHub requires the workflow to exist on the
default branch before offering the [manual run control](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow).

A manual run processes every channel in your matrix unless you add an input and
logic to select a single channel. After a successful first run, enable the daily
schedule. Scheduled workflows are disabled by default in newly forked public
repositories; [enable your workflow](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/disable-and-enable-workflows)
when its configuration is ready.

**Check the result**

Flock's example checks SDK startup, version, channel, and engine pinning, then
resolves its demo app's dependencies, runs analysis and widget tests, and builds
a release web app using the assembled SDK. Use these as a starting point for
your own publication checks, adding native-platform validation where your
changes require it.

The example uploads a `flock-validation-<channel>` artifact with revisions,
version output, and logs. `success.txt` appears only after all validation checks
pass. In your workflow, retain validation reports and confirm that a failed
assembly or validation leaves the corresponding published branch unchanged.
Inspect failures, fix your patches or validation app, and rerun your workflow.

## Custom Engine Builds

The **Build and Upload Flock Engine Variants** workflow builds engine
variants for web, Android, Linux, macOS, and iOS. Use it when your patches change
the Flutter engine and you need binaries that include those changes. Framework-only
patches can normally use the upstream engine pinned during assembly.

The workflow assembles Flutter `master` with `.patches-master` from the patch
repository's `main` branch. It builds the configured Engine Tool variants,
uploads their outputs to Google Cloud Storage, and packages iOS frameworks.
Artifacts are stored under the workflow commit SHA, which the SDK publication
job writes to `bin/internal/engine.version`.

**Configure it**

Treat this workflow as a starting point for your own engine distribution:

1. Set `FLOCK_REPO`, `FLOCK_PATCHES_REPO`, and `REPO_WORKFLOW_PAT` as described
   above. The assembly steps use `FLOCK_PATCHES_REPO` explicitly; set their Git
   identity and checkout paths for your fork.
2. Replace the `flutter-builds` bucket references, including those in the iOS
   packaging steps, with your own storage bucket. Set
   `GOOGLE_STORAGE_BUCKET_SECRET` to a base64-encoded Google Cloud service-account
   JSON key with access to that bucket.
3. Select the platform jobs and build configurations you need. Ensure your SDK's
   artifact download configuration points to your storage location.
4. Keep `push-build` dependent on all required build and packaging jobs. The
   example waits for every platform build and iOS packaging before publishing;
   update that dependency list if you change the jobs. Set an explicit
   destination branch and restrict publication to trusted push runs rather than
   pull-request runs.

**Run it**

After configuration, push changes to Nest's `engine-builds` branch or open a pull
request targeting that branch. Those are the configured triggers; this workflow
does not currently provide a **Run workflow** button.

**Check the result**

Inspect the platform build jobs and the `build-ios-release` packaging job in
GitHub Actions. Confirm that the required binaries exist under the expected
engine revision in your bucket before distributing an SDK that references them.
Engine outputs go to Cloud Storage, not GitHub's downloadable workflow artifacts.

[View the engine build workflow](https://github.com/join-the-flock/nest/blob/main/.github/workflows/build-and-upload-flock-engine-variants.yaml).

## Test Nest Tools

The **Test Nest tools** workflow checks changes to Nest itself. It analyzes and
tests the publication validation script and the `nest_patches` package, including
patch import/export behavior and workflow configuration.

It uses standalone Dart without assembling Flutter, building an engine, or
publishing an SDK. It complements the daily workflow: these tests check the
tools, while daily validation checks a real assembled SDK and demo app.

**Run it**

Open a pull request that changes Nest's tools, patch package, tests,
dependencies, analyzer configuration, assembly action, or related workflows.
The workflow also runs when matching changes are pushed to `main`. Changes to
unrelated files do not trigger it. No publishing credentials are required, and
there is no manual-run trigger.

**Check the result**

Open the **Test Nest tools** check on the pull request or in the **Actions** tab.
The run has separate analysis and test steps for Nest and `nest_patches`. Fix any
reported analyzer errors or failing tests, then push your changes to run the
checks again.

[View the tooling test workflow](https://github.com/join-the-flock/nest/blob/main/.github/workflows/test-nest-tools.yaml).
