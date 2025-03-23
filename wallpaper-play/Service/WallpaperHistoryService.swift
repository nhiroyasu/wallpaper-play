import AppKit
import Injectable

protocol WallpaperHistoryService {
    func store(_ youtube: YouTubeWallpaper)
    func store(_ video: LocalVideoWallpaper)
    func store(_ webpage: WebPageWallpaper)
    func store(_ camera: CameraWallpaper)
    func fetchYouTube() -> [YouTubeWallpaper]
    func fetchVideo() -> [LocalVideoWallpaper]
    func fetchWebPage() -> [WebPageWallpaper]
    func fetchCamera() -> [CameraWallpaper]
    func fetchLatestYouTube() -> YouTubeWallpaper?
    func fetchLatestVideo() -> LocalVideoWallpaper?
    func fetchLatestWebPage() -> WebPageWallpaper?
    func fetchLatestCamera() -> CameraWallpaper?
    func fetchLatestWallpaper() -> WallpaperKind?
}

class WallpaperHistoryServiceImpl: WallpaperHistoryService {
    
    private let realmService: any RealmService
    
    init(injector: any Injectable) {
        realmService = injector.build()
    }
    
    func store(_ youtube: YouTubeWallpaper) {
        let realm = realmService.buildRealm()
        do {
            try realm.write {
                realm.add(youtube)
            }
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }
    
    func store(_ video: LocalVideoWallpaper) {
        let realm = realmService.buildRealm()
        do {
            try realm.write {
                realm.add(video)
            }
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }
    
    func store(_ webpage: WebPageWallpaper) {
        let realm = realmService.buildRealm()
        do {
            try realm.write {
                realm.add(webpage)
            }
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }

    func store(_ camera: CameraWallpaper) {
        let realm = realmService.buildRealm()
        do {
            try realm.write {
                realm.add(camera)
            }
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }

    func fetchYouTube() -> [YouTubeWallpaper] {
        let realm = realmService.buildRealm()
        let results = realm.objects(YouTubeWallpaper.self)
        return results.map { $0 }
    }
    
    func fetchVideo() -> [LocalVideoWallpaper] {
        let realm = realmService.buildRealm()
        let results = realm.objects(LocalVideoWallpaper.self)
        return results.map { $0 }
    }
    
    func fetchWebPage() -> [WebPageWallpaper] {
        let realm = realmService.buildRealm()
        let results = realm.objects(WebPageWallpaper.self)
        return results.map { $0 }
    }

    func fetchCamera() -> [CameraWallpaper] {
        let realm = realmService.buildRealm()
        let results = realm.objects(CameraWallpaper.self)
        return results.map { $0 }
    }

    func fetchLatestYouTube() -> YouTubeWallpaper? {
        let realm = realmService.buildRealm()
        return realm
            .objects(YouTubeWallpaper.self)
            .sorted(byKeyPath: "date", ascending: false)
            .first
    }
    
    func fetchLatestVideo() -> LocalVideoWallpaper? {
        let realm = realmService.buildRealm()
        return realm
            .objects(LocalVideoWallpaper.self)
            .sorted(byKeyPath: "date", ascending: false)
            .first
    }
    
    func fetchLatestWebPage() -> WebPageWallpaper? {
        let realm = realmService.buildRealm()
        return realm
            .objects(WebPageWallpaper.self)
            .sorted(byKeyPath: "date", ascending: false)
            .first
    }

    func fetchLatestCamera() -> CameraWallpaper? {
        let realm = realmService.buildRealm()
        return realm
            .objects(CameraWallpaper.self)
            .sorted(byKeyPath: "date", ascending: false)
            .first
    }

    func fetchLatestWallpaper() -> WallpaperKind? {
        let videoFirst = fetchLatestVideo()
        let youtubeFirst = fetchLatestYouTube()
        let webpageFirst = fetchLatestWebPage()
        let cameraFirst = fetchLatestCamera()

        let videoList: [(any DateSortable)?] = [videoFirst, youtubeFirst, webpageFirst, cameraFirst]
        let latestVideo = videoList.compactMap { $0 }.max { v1, v2 in v1.date < v2.date }
        
        if let video = latestVideo as? LocalVideoWallpaper {
            let videoSize = VideoSize(rawValue: video.config?.size ?? 0) ?? .aspectFill
            let backgroundColor: NSColor? = if let backgroundColorHex = video.config?.backgroundColor {
                NSColor(hex: backgroundColorHex)
            } else {
                nil
            }
            let videoPlayValue = VideoPlayValue(
                url: video.url,
                mute: video.config?.isMute ?? true,
                videoSize: videoSize,
                backgroundColor: backgroundColor
            )
            return .video(value: videoPlayValue)
        } else if let video = latestVideo as? YouTubeWallpaper {
            let videoSize = VideoSize(rawValue: video.size) ?? .aspectFill
            return .youtube(videoId: video.videoId, isMute: video.isMute, videoSize: videoSize)
        } else if let video = latestVideo as? WebPageWallpaper {
            let arrowOperation = video.arrowOperation ?? false
            return .web(
                url: video.url,
                arrowOperation: arrowOperation
            )
        } else if let video = latestVideo as? CameraWallpaper {
            let videoSize = VideoSize(rawValue: video.size) ?? .aspectFill
            return .camera(
                deviceId: video.deviceId,
                videoSize: videoSize
            )
        } else {
            return nil
        }
    }
}
