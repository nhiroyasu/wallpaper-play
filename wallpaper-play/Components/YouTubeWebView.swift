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

    override func mouseEntered(with event: NSEvent) {
        NSCursor.operationNotAllowed.set()
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
}
