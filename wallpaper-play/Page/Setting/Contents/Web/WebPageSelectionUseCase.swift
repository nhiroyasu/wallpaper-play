import Foundation
import Injectable

protocol WebPageSelectionUseCase {
    func validateUrl(string: String) -> URL?
    func requestWallpaper(url: URL, arrowOperation: Bool, target: WallpaperDisplayTarget)
}

class WebPageSelectionInteractor: WebPageSelectionUseCase {
    private let wallpaperRequestService: any WallpaperRequestService
    private let urlValidationService: any UrlValidationService

    init(
        wallpaperRequestService: any WallpaperRequestService,
        urlValidationService: any UrlValidationService
    ) {
        self.wallpaperRequestService = wallpaperRequestService
        self.urlValidationService = urlValidationService
    }

    func requestWallpaper(url: URL, arrowOperation: Bool, target: WallpaperDisplayTarget) {
        wallpaperRequestService.requestWebWallpaper(
            web: WebPlayRequest(
                url: url,
                arrowOperation: arrowOperation,
                target: target
            )
        )
    }

    func validateUrl(string: String) -> URL? {
        return urlValidationService.validate(string: string)
    }
}
