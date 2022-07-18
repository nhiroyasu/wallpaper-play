import Foundation
import AVKit

enum VideoRepeatType {
    case oneLoop
    case listLoop
}

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
    func loop(type: VideoRepeatType) throws
    func loopOff() throws
    func clear()
}

class AVPlayerManagerImpl: AVPlayerManager {
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    
    private var videoContentList: [VideoContent] = []
    func set(_ urls: [URL]) -> AVPlayer {
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
    
    func loop(type: VideoRepeatType) throws {
        guard let player = player, let item = videoContentList.first?.item else {
            throw NSError(domain: "did not set player instance or video contents", code: 1)
        }
        looper = AVPlayerLooper(player: player, templateItem: item)
    }
    
    func loopOff() throws {
        if let looper = looper {
            looper.disableLooping()
        } else {
            throw NSError(domain: "did not set looper", code: 2)
        }
    }
    
    func clear() {
        player?.pause()
        videoContentList.removeAll()
        player = nil
        looper = nil
    }
}
