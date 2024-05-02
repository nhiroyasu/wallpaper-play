import Foundation
import AppKit
import AVFoundation
import Injectable

protocol LocalVideoSelectionPresenter {
    func initViews()
    func setThumbnail(videoUrl: URL)
    func setPreview(videoUrl: URL)
    func setFilePath(videoUrl: URL)
    func removePreview()
    func showError(msg: String)
}

class LocalVideoSelectionPresenterImpl: LocalVideoSelectionPresenter {
    private let avManager: AVPlayerManager
    var output: LocalVideoSelectionViewController!
    var alertManager: AlertManager
    
    init(injector: Injectable) {
        self.avManager = injector.build()
        self.alertManager = injector.build()
    }
    
    func initViews() {
        output.videoView = .init(frame: .zero)
        output.videoView.translatesAutoresizingMaskIntoConstraints = false
        output.videoWrappingView.fitAllAnchor(output.videoView)
    }
    
    func setThumbnail(videoUrl: URL) {
        let generator = AVAssetImageGenerator(asset: AVAsset(url: videoUrl))
        do {
            let image = try generator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), actualTime: nil)
            output.thumbnailImageView.image = image.toNSImage
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }
    
    func setPreview(videoUrl: URL) {
        let player = avManager.set([videoUrl])
        setUpVideoView(player: player)
        do {
            try avManager.mute(true)
            try avManager.loop(type: .oneLoop)
            try avManager.start()
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }
    
    func removePreview() {
        avManager.clear()
        output.videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    private func setUpVideoView(player: AVPlayer) {
        output.videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        output.videoView.setPlayerLayer(layer)
    }
    
    func setFilePath(videoUrl: URL) {
        output.state.modify(\.videoFile, value: videoUrl)
    }
    
    func showError(msg: String) {
        alertManager.warning(msg: msg, completionHandler: {})
    }
}
