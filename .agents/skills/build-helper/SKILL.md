---
name: build-helper
description: Build and test helper for wallpaper-play. Use when Codex needs to run local macOS app build or XCTest from terminal with xcodebuild and format logs via xcbeautify.
---

# Build Helper

`wallpaper-play` のビルドとテストをターミナルから実行する。

## 前提

- リポジトリルート（`wallpaper-play`）で実行する。

## Build を実行する

```sh
xcodebuild -project wallpaper-play.xcodeproj -scheme 'Wallpaper Play' -derivedDataPath .build/DerivedData
```

## Test を実行する

```sh
xcodebuild test -project wallpaper-play.xcodeproj -scheme 'Wallpaper Play' -derivedDataPath .build/DerivedData
```