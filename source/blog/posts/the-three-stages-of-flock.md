---
title: The Three Stages of Flock
description: These are the three major phases of Flock development.
publishDate: 2024-10-31
author: 
  name: Matt Carroll
  avatarUrl: https://secure.gravatar.com/avatar/2b519036dc508c11b0db3463fffbd8ff
---
We recently announced a couple new efforts: Flock, a community fork of Flutter that acts as a 
pressure release valve for Flutter users, and Nest, a collection of tools to help Flutter teams
create their own forks. The tools in Nest will be filled out as they're created to support Flock.
Therefore, Flock is the driving force across the board. These are the high level phases of Flock's
development.

## Phase 1: Mirror the framework
The most important aspect of any long-lived extension fork is the ability to stay up to date with
the upstream changes. We've made it very clear that our goal is to extend and empower Flutter, not
compete with it. So this detail is critical.

The first phase of Flock development is scripting to automatically merge upstream changes
from Flutter into Flock. This involves multiple branches, and tags. Flutter maintains three
permanent branches:

 * master
 * beta
 * stable

The `master` branch constantly receives merges from the team. The `beta` branch receives an update
from `master` about once a month. The `stable` branch receives an update from `beta` about once
every three months.

The Flutter team also tags releases. A tag is a unique identifier that's given to a Git commit so
that the commit can be referenced by other tools and organizations.

Flock will write scripts to keep its own `master`, `beta`, and `stable` branches in sync with
Flutter. Flock will also write scripts to apply the same release tags as Flutter.

These scripts will be added to the Nest toolset.

## Phase 2: Mirror and deliver the engine
Flutter is split into two major pieces: the framework, and the engine. The engine is the part that
contains C++ code, and platform-specific code, like Kotlin, Swift, C#, and JavaScript.

The big difference between the framework and the engine is that the framework is used as source
code (Dart), but the engine is delivered as a pre-compiled binary.

Once Flock mirrors the framework branches, it then needs to run automated builds of the engine
at a regular interval, and upload those engine binaries for consumption by end users. This phase
requires build scripts, upload scripts, cloud storage, and (probably) extensions to the Flutter
CLI tool.

These scripts and tools will be added to the Nest toolset.

By the end of Phase 2, Flock will automatically sync with Flutter in all the ways that matter.
This doesn't mean there won't be merge conflicts in the future, but when there aren't any conflicts,
Flock will automatically add all changes from Flutter, and make those changes available to Flock
users on a daily basis.

## Phase 3: Fixes and extensions
Phase 3 is when the real fun begins. This is when Flock starts fixing bugs and implementing features
that unblock companies that are using Flock. The remainder of Flock's existence will be in Phase 3.

We expect that many Flutter users will be very excited to get their bug fix or feature integrated
as soon as possible in Phase 3. However, the most important thing in Phase 3 is moderation. The
Flock team needs to carefully prove out its strategies and protocols for extending Flutter. It's
critical that the Flock team not overburden itself with likely conflicts. This is a well understood
potential problem, and the Flock team will focus carefully on minimizing this risk.

Moving forward in Phase 3, the team will regularly evaluate opportunities to reduce conflicts, 
minimize divergence, and maximize value. We won't try to be prescriptive about where this leads -
we're excited to see what kind of ideas and opportunities are brought to us by an energetic and
re-invigorated community!

## What you can do now
Flock and Nest are solutions that were motivated by a problem. Our ability to measure success is
dependent upon integrating blocked companies as early as possible.

We'd love to hear from any company that currently, or in the past, has had a release blocked by
Flutter, or has had to take drastic measures to avoid being blocked by Flutter. Our goal is to
minimize any such situations in the future. To help us to do that, please come [chat with us](https://x.com/suprdeclarative) 
about some of those historical issues.