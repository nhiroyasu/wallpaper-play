import Foundation
import Injectable

protocol WebPageSelectionUseCase {
    func validateUrl(string: String) -> URL?
    func requestWallpaper(url: URL)
}

class WebPageSelectionInteractor: WebPageSelectionUseCase {
    private let wallpaperRequestService: WallpaperRequestService
    private let urlValidationService: UrlValidationService

    init(
        wallpaperRequestService: WallpaperRequestService,
        urlValidationService: UrlValidationService
    ) {
        self.wallpaperRequestService = wallpaperRequestService
        self.urlValidationService = urlValidationService
    }

    func requestWallpaper(url: URL) {
        wallpaperRequestService.requestWebWallpaper(url: url)
    }

    func validateUrl(string: String) -> URL? {
        return urlValidationService.validate(string: string)
    }
}
