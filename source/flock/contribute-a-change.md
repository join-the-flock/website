---
title: Contribute a Change
---
# Contribute a Change
Thanks for your interest in contributing to Flock. Flock is a community fork of Flutter,
which means it's a place to add Flutter bug fixes, features, and tool changes that can't
get into Flutter, itself.

Every change to Flock is contributed through something called a "patch file". This guide
shows you how to get started developing for Flock, and contributing patch files for
review.

## Prepare for Development
The following steps prepare you to make changes to Flock.

### Install dependencies
Flutter uses `gclient` to manage its dependencies, which means that Flock also uses
`gclient`. Ensure that you have `gclient` installed.

Check to see if it's already installed:

    which gclient

If it's not installed on your system, install Google's "depot tools" to get it:
[https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)


### Fork the Nest repository
When you're working on Flock, you do so by using the Nest repository. The Nest repository
includes tools for creating the latest version of Flock, and generating a patch file
from your changes.

Visit [https://github.com/join-the-flock/nest](https://github.com/join-the-flock/nest) and
fork the repository with your account so that you can submit pull requests from your
repository to the main Nest repository.

### Clone the Nest repository
Using your fork of the Nest repository, clone the repository locally so that you can work
on Flock.

Clone the Nest repository at a location of your choice:

    git clone git@github.com:[your-account]/nest.git

### Download the latest version of Flutter
Flock is an adjustment on top of Flutter. Therefore, you first need to download the latest
Flutter version into the `nest/flock/` directory.

Run the following command from your `nest` directory:

    # Run the setup script.
    tools/setup.sh

The setup script runs a `gclient sync` to download all Flutter dependencies. This will
take a while.

### Apply all Flock patches to Flutter
Now that you have the latest Flutter version, you need to play back all the Flock
patches, to turn Flutter into Flock.

Run the following command from your `nest/` directory:

    # Run the patch import script with all patches in the nest/patches/ directory.
    tools/git-import-patches patches

Once this command completes, your `nest/flock/` directory contains the latest version
of Flock, and it's ready for development.

At this point you can make whatever changes you'd like to Flock. When committing your
work, make sure that you commit from within the `nest/flock/` directory, not the root
`nest/` directory. Also, make sure that all of your changes are placed in a single Git 
commit. Don't create multiple commits for your change.

## Submit your change for review
Once you've made changes to Flock that you're ready to commit, it's time to generate
a patch file and submit it for review.

### Generate a patch file
Flock doesn't use Git to track its changes to Flutter. Instead, Flock collects a bunch
of "patch files" and replays them on top of Flutter. To contribute your changes to 
Flock, you first need to convert your changes to a patch file.

If you haven't committed your changes to `nest/flock/`, do that now. Ensure that all of
your changes are in a single Git commit. This way you'll generate exactly one patch file.

From your `nest` directory, run the following command:

    # Export your commit as a patch file.
    tools/git-export-patches -o patches

After exporting patches, check your `nest/patches/` directory. You should see a new patch
that includes all of your changes.

### Register your patch file with Nest
Nest only applies patches that are listed in its patch configuration file.

Open `nest/patches/.patches` and ensure that the name of your patch file appears in the
list. This list should have been updated when you ran the `git-export-patches` script.

### Create a Pull Request for review
Add and commit your new patch file to Nest.

Hypothetical example:

    git add patches
    git commit -m "[Flock] - Some description of your change (Resolves #1234)"
    git push origin my_branch

Go to GitHub and open a Pull Request from your branch to the main Nest repository.

Include all relevant information in your PR to help with a quick and effective review.
