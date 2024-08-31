import Foundation
import Injectable
import RealmSwift
import AppKit

protocol ApplicationService {
    func applicationDidFinishLaunching()
    func applicationOpen(urls: [URL])
    func applicationShouldHandleReopen(hasVisibleWindows flag: Bool) -> Bool
    func didBecomeActive()
    func didTapWallPaperItem()
    func didTapPreferenceItem()
    func didTapOpenRealm()
    func dockMenu() -> NSMenu
}

class ApplicationServiceImpl: ApplicationService {
    
    private let realmService: RealmService
    private let notificationManager: NotificationManager
    private let wallpaperWindowService: WallpaperWindowService
    private let videoFormWindowPresenter: VideoFormWindowPresenter
    private let wallpaperHistoryService: WallpaperHistoryService
    private let applicationFileManager: ApplicationFileManager
    private let fileManager: FileManager
    private let userSetting: UserSettingService
    private let youtubeContentService: YouTubeContentsService
    private let urlResolverService: URLResolverService
    private let urlValidationService: UrlValidationService
    private let appManager: AppManager
    private let dockMenuBuilder: DockMenuBuilder

    init(injector: Injectable) {
        realmService = injector.build()
        notificationManager = injector.build()
        wallpaperWindowService = injector.build()
        videoFormWindowPresenter = injector.build()
        wallpaperHistoryService = injector.build()
        applicationFileManager = injector.build()
        userSetting = injector.build()
        youtubeContentService = injector.build()
        urlResolverService = injector.build()
        urlValidationService = injector.build()
        appManager = injector.build()
        fileManager = .default
        dockMenuBuilder = injector.build()
    }
    
    private var setUpFlag = false
    private func setUp() {
        guard setUpFlag == false else { return }
        setUpRequestYouTubeNotification()
        setUpRequestVideoNotification()
        setUpRequestVisibilityIconNotification()
        setUpRequestWebPageNotification()
        setUpAppIcon()
        setUpFlag = true
    }

    func applicationDidFinishLaunching() {
        setUp()
        if wallpaperWindowService.isVisibleWallpaperWindow() == false {
            displayLatestWallpaper()
            openVideoFormIfNeeded()
        }
    }

    func applicationOpen(urls: [URL]) {
        setUp()
        guard let url = urls.first else { return }
        guard let (videoId, isMute) = getWallpaperData(from: url) else { return }
        displayYouTube(videoId: videoId, isMute: isMute, shouldSavedHistory: true)
        videoFormWindowPresenter.close()
    }

    func applicationShouldHandleReopen(hasVisibleWindows flag: Bool) -> Bool {
        videoFormWindowPresenter.show()
        return false
    }

    func didBecomeActive() {}

        func didTapWallPaperItem() {
        videoFormWindowPresenter.show()
        appManager.activate()
    }
    
    func didTapPreferenceItem() {
        videoFormWindowPresenter.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.notificationManager.push(name: .selectedSideMenu, param: SideMenuItem.preference)
        }
        appManager.activate()
    }

    func didTapOpenRealm() {
        if let url = realmService.getRealmURL() {
            NSWorkspace.shared.open(url)
        }
    }

    func dockMenu() -> NSMenu {
        dockMenuBuilder.build()
    }

    private func setUpRequestYouTubeNotification() {
        notificationManager.observe(name: .requestYouTube) { [weak self] param in
            guard let self = self, let data = param as? YouTubePlayValue else { fatalError() }
            self.displayYouTube(videoId: data.videoId, isMute: data.isMute, shouldSavedHistory: true)
        }
    }
    
    private func setUpRequestWebPageNotification() {
        notificationManager.observe(name: .requestWebPage) { [weak self] param in
            guard let self = self, let url = param as? URL else { fatalError() }
            self.displayWebPage(url: url, shouldSavedHistory: true)
        }
    }
    
    private func displayYouTube(videoId: String, isMute: Bool, shouldSavedHistory: Bool) {
        wallpaperWindowService.display(wallpaperKind: .youtube(videoId: videoId, isMute: isMute))

        if shouldSavedHistory {
            let youtubeWallpaper = YouTubeWallpaper(date: Date(), videoId: videoId, isMute: isMute)
            wallpaperHistoryService.store(youtubeWallpaper)
        }
    }
    
    private func displayWebPage(url: URL, shouldSavedHistory: Bool) {
        wallpaperWindowService.display(wallpaperKind: .web(url: url))

        if shouldSavedHistory {
            let webpageWallpaper = WebPageWallpaper(date: Date(), url: url)
            wallpaperHistoryService.store(webpageWallpaper)
        }
    }
    
    private func setUpRequestVideoNotification() {
        notificationManager.observe(name: .requestVideo) { [weak self] param in
            guard let self = self, let value = param as? VideoPlayValue else { fatalError() }
            self.displayLocalVideo(value: value, shouldSavedHistory: true)
        }
    }
    
    private func displayLocalVideo(value: VideoPlayValue, shouldSavedHistory: Bool) {
        wallpaperWindowService.display(wallpaperKind: .video(value: value))

        if shouldSavedHistory {
            guard let latestVideoStore = applicationFileManager.getDirectory(.latestVideo) else { return }
            let storedFileUrl = latestVideoStore.appendingPathComponent("latest.\(value.url.pathExtension)")
            do {
                if fileManager.fileExists(atPath: storedFileUrl.path) {
                    try fileManager.removeItem(at: storedFileUrl)
                }
                try fileManager.copyItem(at: value.url, to: storedFileUrl)
                let localVideoWallpaper = LocalVideoWallpaper(
                    date: Date(),
                    url: storedFileUrl,
                    config: .init(size: value.videoSize.rawValue, isMute: value.mute)
                )
                wallpaperHistoryService.store(localVideoWallpaper)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    private func displayLatestWallpaper() {
        if let latestWallpaper = wallpaperHistoryService.fetchLatestWallpaper() {
            wallpaperWindowService.display(wallpaperKind: latestWallpaper)
        }
    }
    
    private func setUpAppIcon() {
        appManager.setVisibilityIcon(userSetting.visibilityIcon)
    }
    
    private func setUpRequestVisibilityIconNotification() {
        notificationManager.observe(name: .requestVisibilityIcon) { [weak self] _ in
            guard let self = self else { return }
            self.appManager.setVisibilityIcon(self.userSetting.visibilityIcon)
        }
    }

    private func openVideoFormIfNeeded() {
        if userSetting.openThisWindowAtFirst {
            videoFormWindowPresenter.show()
        }
    }

    private func getWallpaperData(from urlSchema: URL) -> (videoId: String, isMute: Bool)? {
        guard urlValidationService.validateAsUrlSchema(url: urlSchema) else { return nil }
        let components = NSURLComponents(url: urlSchema, resolvingAgainstBaseURL: false)
        guard let urlItem = components?.queryItems?.first(where: { item in item.name == "youtube-url" }) else { return nil }
        guard let isMuteItem = components?.queryItems?.first(where: { item in item.name == "is-mute" }) else { return nil }
        guard let youtubeLink = urlItem.value else { return nil }
        let isMute = isMuteItem.value == "true"
        if let videoId = youtubeContentService.getVideoId(youtubeLink: youtubeLink) {
            return (videoId, isMute)
        } else {
            return nil
        }
    }
}
