class AppState {
    static let shared = AppState()

    private init() {}

    struct Wallpaper {
        let screenIdentifier: UInt32
        let kind: WallpaperKind
    }

    var wallpapers: [Wallpaper] = []
}

