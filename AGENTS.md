# Repository Guidelines

## Project Structure & Module Organization
- `wallpaper-play/` contains the macOS app source (Swift, XIBs, storyboards, assets).
- `wallpaper-play/Service/`, `Entity/`, `Page/`, `Components/`, and `Util/` group core logic, domain models, UI flows, reusable views, and helpers.
- `Wallpaper Paly SafariEextension/` hosts the Safari Web Extension (Swift handler + `Resources/` HTML/CSS/JS).
- Tests live in `wallpaper-playTests/` (unit) and `wallpaper-playUITests/` (UI).
- Static assets are under `wallpaper-play/Assets.xcassets/` and `wallpaper-play/BundleAssets/`. App previews sit in `previews/`.

## Build, Test, and Development Commands
Use Xcode for day-to-day development: open `wallpaper-play.xcodeproj`.
Command-line examples:
```sh
xcodebuild -scheme "Wallpaper Play" -configuration Debug build
xcodebuild test -scheme "Wallpaper Play" -destination "platform=macOS"
```
Use the scheme that matches your target (see `wallpaper-play.xcodeproj/xcshareddata/xcschemes/`).

## Coding Style & Naming Conventions
- Swift code uses 4-space indentation and standard Apple API naming (CamelCase types, lowerCamelCase members).
- Keep file, type, and XIB names aligned (e.g., `WallpaperViewController.swift` + `WallpaperViewController.xib`).
- Follow the existing folder organization and naming patterns when adding new screens or services.

## Testing Guidelines
- Tests are written with XCTest in `wallpaper-playTests/` and `wallpaper-playUITests/`.
- Name tests descriptively (e.g., `YouTubeContentsServiceTests`).
- Run unit and UI tests via Xcode or `xcodebuild test` as above.

## Commit & Pull Request Guidelines
- Recent commits use short, imperative sentences (e.g., “Update version 1.8.0”, “Fixed a bug…”). Follow that style.
- Include a clear PR description, list of changes, and screenshots/GIFs when UI is affected.
- Link related issues and note any migration or data-impacting changes.

## Configuration & Localization Notes
- Privacy details are maintained in `PrivacyInfo.xcprivacy` and entitlements in `wallpaper-play/*.entitlements`.
- Localized strings live in `wallpaper-play/ja.lproj/` and `wallpaper-play/en.lproj/`.
