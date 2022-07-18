import Foundation
import Injectable

protocol WebPageSelectionPresenter {
    func setPreview(url: URL)
    func clearPreview()
    func setUpWallpaper(for url: URL)
    func showAlert(message: String)
}

class WebPageSelectionPresenterImpl: WebPageSelectionPresenter {
    private var state: WebPageSelectionState
    private let notificationManager: NotificationManager
    private let alertManager: AlertManager
    
    init(injector: Injectable, state: WebPageSelectionState) {
        self.state = state
        self.notificationManager = injector.build()
        self.alertManager = injector.build()
    }
    
    func setPreview(url: URL) {
        state.previewUrl = url
        state.isEnableSetWallpaperButton = true
    }
    
    func clearPreview() {
        state.previewUrl = nil
        state.isEnableSetWallpaperButton = false
    }
    
    func setUpWallpaper(for url: URL) {
        notificationManager.push(name: .requestWebPage, param: url)
    }
    
    func showAlert(message: String) {
        alertManager.warning(msg: message, completionHandler: {})
    }
}
