import WebKit

extension WKWebViewConfiguration {
    static func youtubeWallpaper(videoSize: VideoSize) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        
        if videoSize == .aspectFill {
            let videoScaleObserverScript = createVideoScaleObserverScript()
            configuration.userContentController.addUserScript(videoScaleObserverScript)
        }
        
        return configuration
    }
    
    static let webWallpaper: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        return configuration
    }()
    
    static func createVideoScaleObserverScript() -> WKUserScript {
        guard let scriptURL = Bundle.main.url(forResource: "video_scaler", withExtension: "js"),
              let jsCode = try? String(contentsOf: scriptURL) else {
            fatalError("Failed to load JS script")
        }
        return WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
}
