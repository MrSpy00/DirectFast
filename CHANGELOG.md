# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project follows Semantic Versioning.

## [Unreleased]

### Fixed

- Improved History screen rendering for compact devices and long contact labels.
- Added resilient history deserialization so malformed records no longer hide valid entries.
- Updated Android release signing flow to use stable keystore configuration, preventing signature-related install/update failures.

### Documentation

- Improved contribution workflow and QA expectations in `CONTRIBUTING.md`.
- Synced README sections for tests, CI/CD, release APK, and sponsorship in Turkish and English.

## [1.0.0] - 2026-04-17

### Added

- Initial production release.
- 18-platform quick chat flow without contact saving.
- Smart clipboard parsing, deep links, backup/restore, privacy dashboard.
- Security toolkit, advanced QR studio, and localization infrastructure.
- Public release APK distribution via GitHub Releases.
- CI/CD pipeline with analyze, test, and release APK build automation.
- Community templates for bug report, feature request, and contribution flow.
