import Foundation
import WebKit

class YoutubeWebView: WKWebView {
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        translatesAutoresizingMaskIntoConstraints = false
        allowsBackForwardNavigationGestures = true
        allowsLinkPreview = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
