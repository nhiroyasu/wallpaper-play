import Foundation
import Injectable

protocol WebPageSelectionPresenter {
    func setPreview(url: URL)
    func clearPreview()
    func showAlert(message: String)
}

class WebPageSelectionPresenterImpl: WebPageSelectionPresenter {
    private let notificationManager: NotificationManager
    private let alertManager: AlertManager
    var output: WebPageSelectionViewController!

    init(injector: Injectable) {
        self.notificationManager = injector.build()
        self.alertManager = injector.build()
    }
    
    func setPreview(url: URL) {
        output.previewWebView.load(URLRequest(url: url))
    }
    
    func clearPreview() {
        output.previewWebView.loadHTMLString("", baseURL: nil)
    }

    func showAlert(message: String) {
        alertManager.warning(msg: message, completionHandler: {})
    }
}
