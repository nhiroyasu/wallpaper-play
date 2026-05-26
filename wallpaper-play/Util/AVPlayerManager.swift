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

    // Looper: Used when there is only one video being played
    private var playerLooper: AVPlayerLooper?
    // An Observer for looping when there are two or more videos playing
    private var endObserverForLooper2: (any NSObjectProtocol)?
    private var isLooping = false
    
    private var videoContentList: [VideoContent] = []

    deinit {
        removeEndObserver()
    }

    func set(_ urls: [URL]) -> AVPlayer {
        playerLooper?.disableLooping()
        playerLooper = nil
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
        guard let player = player, !videoContentList.isEmpty else {
            throw NSError(domain: "did not set player instance or video contents", code: 1)
        }
        guard !isLooping else { return }

        isLooping = true
        if videoContentList.count == 1 {
            player.removeAllItems()
            playerLooper = AVPlayerLooper(player: player, templateItem: videoContentList[0].item)
        } else {
            endObserverForLooper2 = NotificationCenter.default.addObserver(
                forName: AVPlayerItem.didPlayToEndTimeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                self?.queueDidFinish(notification)
            }
        }
    }
    
    func loopOff() throws {
        guard isLooping else {
            throw NSError(domain: "did not set looper", code: 2)
        }
        isLooping = false
        playerLooper?.disableLooping()
        playerLooper = nil
        removeEndObserver()
    }
    
    func clear() {
        playerLooper?.disableLooping()
        playerLooper = nil
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
        guard let endObserverForLooper2 else { return }
        NotificationCenter.default.removeObserver(endObserverForLooper2)
        self.endObserverForLooper2 = nil
    }
}
