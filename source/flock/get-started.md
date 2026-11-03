---
title: Get Started with Flock
description: Switch from Flutter to Flock with Flutter Version Manager, then configure your project to use the Flock fork.
code_examples: true
---
# Get Started

## Use FVM
Use <a href="https://fvm.app/">Flutter Version Manager (FVM)</a> to switch from Flutter to Flock, and back. Use FVM version 4.0, or later.

## Use Flock
Open your project and run these commands:

```bash
# Add Flock as a Flutter fork, in FVM, globally.
fvm fork add flock https://github.com/join-the-flock/flock.git

# Configure your project to use Flock.
fvm use flock/stable

# Download Flock.
fvm install flock/stable
```

Use any `fvm` Flutter command, like `fvm flutter --version` or `fvm flutter build`.

Within your project, FVM commands will be sent to the Flock version of Flutter.

## Manual Configuration
If you'd rather configure FVM directly, you can get the same result by editing a couple
configuration files.

Add Flock as a Flutter fork to your global FVM configuration file:

```json
{
  "forks": [
    {
      "name": "flock",
      "url": "https://github.com/join-the-flock/flock.git"
    }
  ]
}
```

Choose the Flock fork in your project's `.fvmrc` file:

```json
{
  "flutter": "flock/stable"
}
```

After making these two changes, any FVM command that you run in your project, such
as `fvm flutter --version`, will download and use the Flock fork.
