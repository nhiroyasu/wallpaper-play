import Foundation
import AVKit

struct VideoContent {
    let asset: AVAsset
    let item: AVPlayerItem
    
    init(url: URL) {
        asset = .init(url: url)
        item = .init(asset: asset)
    }
}

protocol AVPlayerManager {
    func set(_ urls: [URL]) -> AVPlayer
    func start() throws
    func stop() throws
    func mute(_ value: Bool) throws
    func loop() throws
    func loopOff() throws
    func clear()
}

class AVPlayerManagerImpl: AVPlayerManager {
    private var player: AVQueuePlayer?
    private var endObserver: NSObjectProtocol?
    private var isLooping = false
    
    private var videoContentList: [VideoContent] = []

    deinit {
        removeEndObserver()
    }

    func set(_ urls: [URL]) -> AVPlayer {
        player?.pause()
        player?.removeAllItems()
        removeEndObserver()
        isLooping = false
        videoContentList = urls.map { .init(url: $0) }
        let player = AVQueuePlayer(items: videoContentList.map { $0.item })
        self.player = player
        return player
    }
    
    func start() throws {
        guard let player = player else {
            throw NSError(domain: "did not set player instance", code: 1)
        }
        player.play()
    }
    
    func stop() throws {
        guard let player = player else {
            throw NSError(domain: "did not set player instance", code: 1)
        }
        player.pause()
    }
    
    func mute(_ value: Bool) throws {
        guard let player = player else {
            throw NSError(domain: "did not set player instance", code: 1)
        }
        player.isMuted = value
    }
    
    func loop() throws {
        guard player != nil, !videoContentList.isEmpty else {
            throw NSError(domain: "did not set player instance or video contents", code: 1)
        }
        guard endObserver == nil else { return }
        isLooping = true
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.queueDidFinish(notification)
        }
    }
    
    func loopOff() throws {
        guard endObserver != nil, isLooping else {
            throw NSError(domain: "did not set looper", code: 2)
        }
        isLooping = false
        removeEndObserver()
    }
    
    func clear() {
        player?.pause()
        player?.removeAllItems()
        removeEndObserver()
        isLooping = false
        videoContentList.removeAll()
        player = nil
    }

    private func queueDidFinish(_ notification: Notification) {
        guard isLooping else { return }
        guard let item = notification.object as? AVPlayerItem else { return }
        guard videoContentList.contains(where: { $0.item === item }) else { return }
        item.seek(to: .zero) { [weak self] _ in
            self?.player?.insert(item, after: nil)
        }
    }

    private func removeEndObserver() {
        guard let endObserver else { return }
        NotificationCenter.default.removeObserver(endObserver)
        self.endObserver = nil
    }
}
