import Cocoa
import AVKit

class VideoView: NSView {
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        self.wantsLayer = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("not called")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    func setPlayerLayer(_ playerLayer: AVPlayerLayer) {
        playerLayer.frame = frame
        self.layer?.addSublayer(playerLayer)
    }
}
