import Foundation
import Injectable

protocol WallpaperHistoryService {
    func store(_ youtube: YouTubeWallpaper)
    func store(_ video: LocalVideoWallpaper)
    func store(_ webpage: WebPageWallpaper)
    func fetchYouTube() -> [YouTubeWallpaper]
    func fetchVideo() -> [LocalVideoWallpaper]
    func fetchWebPage() -> [WebPageWallpaper]
    func fetchLatestYouTube() -> YouTubeWallpaper?
    func fetchLatestVideo() -> LocalVideoWallpaper?
    func fetchLatestWebPage() -> WebPageWallpaper?
    func fetchLatestWallpaper() -> WallpaperKind?
}

class WallpaperHistoryServiceImpl: WallpaperHistoryService {
    
    private let realmService: RealmService
    
    init(injector: Injectable) {
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
    
    func fetchLatestWallpaper() -> WallpaperKind? {
        let videoFirst = fetchLatestVideo()
        let youtubeFirst = fetchLatestYouTube()
        let webpageFirst = fetchLatestWebPage()
        
        let videoList: [DateSortable?] = [videoFirst, youtubeFirst, webpageFirst]
        let latestVideo = videoList.compactMap { $0 }.max { v1, v2 in v1.date < v2.date }
        
        if let video = latestVideo as? LocalVideoWallpaper {
            let videoPlayValue = VideoPlayValue(
                urls: Array(video.urls),
                mute: true,
                videoSize: VideoSize(rawValue: video.config?.size ?? 0) ?? .aspectFill
            )
            return .video(value: videoPlayValue)
        } else if let video = latestVideo as? YouTubeWallpaper {
            return .youtube(url: video.url)
        } else if let video = latestVideo as? WebPageWallpaper {
            return .web(url: video.url)
        } else {
            return nil
        }
    }
}
