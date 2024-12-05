---
title: Get Started with Flock
---
# Get Started

<section class="page-intro">
  <p><span class="emphasis">Flock is Flutter+</span>  •  Flock is a fork of Flutter. Flock stays up to date with Flutter, and also adds new community features.</p>
</section>

Configure your Flutter project to use Flock.

<p class="side-note">For now, Flock is just a direct copy of Flutter. We're working on smoothing out the
  synchronization process on GitHub. We encourage you to start using Flock, which should
  exactly match Flutter's current <code>master</code> branch. If you run into any difficulties,
  please <a href="https://github.com/join-the-flock/nest" target="_blank">file an issue with us</a> so we can fix it!</p>

## Install FVM
Flutter Version Manager (FVM) let's you install and use multiple versions of Flutter on the same 
machine. To use Flock, start by <a href="https://fvm.app/documentation/getting-started/installation" target="_blank">installing FVM</a>.

## Existing FVM Installation
Because of the way that FVM identifies Flutter versions, if you've already installed Flutter 
`master` with FVM, you'll need to delete that version before using Flock.

To delete an existing version, locate your FVM cache directory, and then delete the subdirectory 
called "master".

## Configure FVM for Your Project
Select a Flutter project where you'd like to use Flock. In that project, create a new file
called `.fvmrc` at the root of the Flutter project.

Configure `.fvmrc` to use Flock:

    {
      "flutter": "master",
      "flutterUrl": "https://github.com/join-the-flock/flock.git"
    }

## Install Flock
Open a terminal at your project directory and run `fvm flutter --version`. FVM should 
notify you that "Master" is not installed, and then prompt you to install it.

    Flutter SDK: Channel: Master is not installed.
    ? Would you like to install it now? (y/n) › yes

Select "yes" to install the Flock version of Flutter to your FVM cache.

## Verify Flock Installation
To verify that your Flock installation worked, run `fvm flutter --version`. Ensure
  that your Flutter git URL points to `https://github.com/join-the-flock/flutter.git`.

    Flutter 3.27.0-1.0.pre.200 • channel master • https://github.com/join-the-flock/flock.git
    Framework • revision 452ef96537 (16 hours ago) • 2024-10-22 12:37:14 +0000
    Engine • revision e6856502b5
    Tools • Dart 3.7.0 (build 3.7.0-47.0.dev) • DevTools 2.40.1</code></pre>

## Using Flock
You're now setup to use Flock! Run all of your usual Flutter commands through FVM.

    fvm flutter --version
    
    fvm flutter pub get
    
    fvm flutter run
    
    fvm flutter build

    etc.

Within your project, FVM commands will be sent to the Flock version of Flutter.
