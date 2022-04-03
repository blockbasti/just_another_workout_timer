<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
<a href="https://weblate.bblock.dev/engage/just-another-workout-timer/">
<img src="https://weblate.bblock.dev/widgets/just-another-workout-timer/-/app/svg-badge.svg" alt="Übersetzungsstatus" />
</a>
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/X8X8827HU)
![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/blockbasti/just_another_workout_timer/CI/main?style=for-the-badge)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/blockbasti/just_another_workout_timer?style=for-the-badge)
![F-Droid](https://img.shields.io/f-droid/v/com.blockbasti.justanotherworkouttimer?style=for-the-badge)

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/blockbasti/just_another_workout_timer">
    <img src="/assets/ic_launcher.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Just Another Workout Timer</h3>

  <p align="center">
    A simple timer for your workouts, built with Flutter!
    <br />
    <a href="https://f-droid.org/packages/com.blockbasti.justanotherworkouttimer">
        <img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
        alt="Get it on F-Droid"
             height="80"></a>
    <a href="https://github.com/blockbasti/just_another_workout_timer/releases/latest">
        <img src="/assets/get-it-on-github.png"
        alt="Get it on GitHub"
             height="80"></a>
    <br />
      <p>
        NOTE: Due to the process of releasing updates on F-Droid, the version there can be outdated for a few days.
        The version on GitHub will always be the latest. Keep in mind, that the F-Droid and GitHub versions are not compatible with each other.
        If you switch, you will loose ALL your data. You need to  <a href="#how-to-backup--restore-your-workouts">backup your workouts</a> to keep them.
      </p>


<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#screenshots">Screenshots</a></li>
		<li><a href="#how-to-backup--restore-your-workouts">How To Backup & Restore Your Workouts</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

* Create complex workouts easily
* Define your own exercises with custom durations
* Add exercises to custom sets
* Text-to-Speech announcements
* Modern Material Design built with Flutter
* Ad-free
* Free and Open-Source

### Screenshots

<img src="/fastlane/metadata/android/en-US/images/phoneScreenshots/1.jpg" alt="Workout Screen" width="250">
<img src="/fastlane/metadata/android/en-US/images/phoneScreenshots/2.jpg" alt="Home Screen" width="250">
<img src="/fastlane/metadata/android/en-US/images/phoneScreenshots/3.jpg" alt="Builder Screen" width="250">
<img src="/fastlane/metadata/android/en-US/images/phoneScreenshots/4.jpg" alt="Settings Screen" width="250">

### How To Backup & Restore Your Workouts
You can export individual workouts or create an export of all your workouts and import them later. You can also transfer them to another device.

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/blockbasti/just_another_workout_timer/issues) for a list of proposed features (and known issues).

<!-- CONTRIBUTING -->
## Contributing

<a href="https://weblate.bblock.dev/engage/just-another-workout-timer/">
<img src="https://weblate.bblock.dev/widgets/just-another-workout-timer/-/open-graph.png" alt="Übersetzungsstatus" />
</a>

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Building the app

1. Run `flutter pub get`
2. Run `./scripts/generate_code.sh` or 
`flutter pub run flutter_oss_licenses:generate.dart` and
`flutter pub run intl_utils:generate` to generate licenses and translations
3. Run `flutter build apk` or run using your IDE

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/blockbasti/just_another_workout_timer.svg?style=for-the-badge
[contributors-url]: https://github.com/blockbasti/just_another_workout_timer/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/blockbasti/just_another_workout_timer.svg?style=for-the-badge
[forks-url]: https://github.com/blockbasti/just_another_workout_timer/network/members
[stars-shield]: https://img.shields.io/github/stars/blockbasti/just_another_workout_timer.svg?style=for-the-badge
[stars-url]: https://github.com/blockbasti/just_another_workout_timer/stargazers
[issues-shield]: https://img.shields.io/github/issues/blockbasti/just_another_workout_timer.svg?style=for-the-badge
[issues-url]: https://github.com/blockbasti/just_another_workout_timer/issues
[license-shield]: https://img.shields.io/github/license/blockbasti/just_another_workout_timer.svg?style=for-the-badge
[license-url]: https://github.com/blockbasti/just_another_workout_timer/blob/master/LICENSE
