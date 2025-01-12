---
title: Setup to Contribute
---
# Setup to Contribute
Thanks for your interest in contributing to Flock. Flock is a community fork of Flutter,
which means it's a place to add Flutter bug fixes, features, and tool changes that can't
get into Flutter, itself.

This guide walks you through the steps to setup your machine to contribute changes to Flock.

## Install dependencies
Flutter uses `gclient` to manage its dependencies, which means that Flock also uses
`gclient`. Ensure that you have `gclient` installed.

Check to see if it's already installed:

    which gclient

If it's not installed on your system, install Google's "depot tools" to get it:
[https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)


## Fork the Nest repository
When you're working on Flock, you do so by using the Nest repository. The Nest repository
includes tools for creating the latest version of Flock, and generating a patch file
from your changes.

Visit [https://github.com/join-the-flock/nest](https://github.com/join-the-flock/nest) and
fork the repository with your account so that you can submit pull requests from your
repository to the main Nest repository.

## Clone the Nest repository
Using your fork of the Nest repository, clone the repository locally so that you can work
on Flock.

Clone the Nest repository at a location of your choice:

    git clone git@github.com:[your-account]/nest.git

## Setup Flutter within Nest
Flock is an adjustment on top of Flutter. Therefore, you first need to download the latest
Flutter version into the `nest/flock/` directory.

Run the following command from your `nest` directory:

    # Run the setup script.
    tools/setup.sh

The setup script runs a `gclient sync` to download all Flutter dependencies. This will
take a while.

## Create Flock within Nest
Now that you have the latest Flutter version, you need to play back all the Flock
patches, to turn Flutter into Flock.

Run the following command from your `nest/` directory:

    # Run the patch import script with all patches in the nest/patches/ directory.
    tools/git-import-patches patches

Once this command completes, your `nest/flock/` directory contains the latest version
of Flock, and it's ready for development.

## Submit your changes
When you're ready to submit your changes to Flock, follow the steps in [contribute a change](contribute-a-change).
