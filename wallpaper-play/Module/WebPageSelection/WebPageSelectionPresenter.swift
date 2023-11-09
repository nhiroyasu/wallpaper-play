import Foundation
import Injectable
import WebKit
import UniformTypeIdentifiers

protocol WebPageSelectionPresenter {
    func setPreview(url: URL)
    func clearPreview()
    func setUpWallpaper(for url: URL)
    func showAlert(message: String)
}

class WebPageSelectionPresenterImpl: NSObject, WebPageSelectionPresenter, WKNavigationDelegate {
    private var state: WebPageSelectionState
    private let notificationManager: NotificationManager
    private let alertManager: AlertManager
    private var thumbnailLoader: WKWebView?
    
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
        
        if let mainframe = NSScreen.main?.frame {
            let thumbview = WKWebView(frame: mainframe)
            thumbview.navigationDelegate = self
            thumbview.load(URLRequest(url: url))
            self.thumbnailLoader = thumbview
        } else {
            notificationManager.push(name: .requestWebPage, param: url)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.takeSnapshot(with: WKSnapshotConfiguration(), completionHandler: { snapshotImage, error in
            if let image = snapshotImage, var mainframe = NSScreen.main?.frame {
                let cgimage = image.cgImage(forProposedRect: &mainframe, context: nil, hints: nil)
                if let dest = CGImageDestinationCreateWithURL(ApplicationFileManagerImpl().getDirectory(.latestThumb)!.appendingPathComponent("latest.png") as CFURL, kUTTypePNG, 1, nil), let cgimage = cgimage {
                    CGImageDestinationAddImage(dest, cgimage, nil)
                    CGImageDestinationFinalize(dest)
                }
            } else {
                print(error?.localizedDescription as Any)
            }
            self.notificationManager.push(name: .requestWebPage, param: self.state.previewUrl!) // I missed self, resulting in a "type of expression is ambigious", but I only got the clue for that when I downgraded to Xcode 13.4...
            self.thumbnailLoader = nil
        })
    }
    
    func showAlert(message: String) {
        alertManager.warning(msg: message, completionHandler: {})
    }
}
