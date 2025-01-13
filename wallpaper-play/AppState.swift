class AppState {
    static let shared = AppState()

    private init() {}

    var wallpaperKind: WallpaperKind? = nil
}

