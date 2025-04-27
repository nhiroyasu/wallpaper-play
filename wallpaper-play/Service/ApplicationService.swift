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
    
    private let realmService: any RealmService
    private let notificationManager: any NotificationManager
    private let wallpaperWindowService: any WallpaperWindowService
    private let settingWindowService: any SettingWindowService
    private let wallpaperHistoryService: any WallpaperHistoryService
    private let applicationFileManager: any ApplicationFileManager
    private let fileManager: FileManager
    private let userSetting: any UserSettingService
    private let youtubeContentService: any YouTubeContentsService
    private let urlResolverService: any URLResolverService
    private let urlValidationService: any UrlValidationService
    private let appManager: any AppManager
    private let dockMenuBuilder: any DockMenuBuilder

    init(injector: any Injectable) {
        realmService = injector.build()
        notificationManager = injector.build()
        wallpaperWindowService = injector.build()
        settingWindowService = injector.build()
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
        setUpRequestCameraNotification()
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
        displayYouTube(videoId: videoId, isMute: isMute, shouldSavedHistory: true, videoSize: .aspectFit, target: .sameOnAllMonitors)
        settingWindowService.close()
    }

    func applicationShouldHandleReopen(hasVisibleWindows flag: Bool) -> Bool {
        settingWindowService.show()
        return false
    }

    func didBecomeActive() {}

        func didTapWallPaperItem() {
        settingWindowService.show()
        appManager.activate()
    }
    
    func didTapPreferenceItem() {
        settingWindowService.show()
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

    private func setUpRequestVideoNotification() {
        notificationManager.observe(name: .requestVideo) { [weak self] param in
            guard let self = self, let request = param as? VideoPlayRequest else { fatalError() }
            self.displayLocalVideo(request: request, shouldSavedHistory: true)
        }
    }

    private func setUpRequestYouTubeNotification() {
        notificationManager.observe(name: .requestYouTube) { [weak self] param in
            guard let self = self, let request = param as? YouTubePlayRequest else { fatalError() }
            self.displayYouTube(videoId: request.videoId, isMute: request.isMute, shouldSavedHistory: true, videoSize: request.videoSize, target: request.target)
        }
    }
    
    private func setUpRequestWebPageNotification() {
        notificationManager.observe(name: .requestWebPage) { [weak self] param in
            guard let self = self, let request = param as? WebPlayRequest else { fatalError() }
            self.displayWebPage(url: request.url, arrowOperation: request.arrowOperation, shouldSavedHistory: true, target: request.target)
        }
    }

    private func setUpRequestCameraNotification() {
        notificationManager.observe(name: .requestCamera) { [weak self] param in
            guard let self = self, let request = param as? CameraPlayRequest else { fatalError() }
            self.wallpaperWindowService.display(
                wallpaperKind: WallpaperKind.camera(deviceId: request.deviceId, videoSize: request.videoSize),
                target: request.target
            )
            self.wallpaperHistoryService.store(CameraWallpaper(date: Date(), deviceId: request.deviceId, size: request.videoSize.rawValue))
        }
    }

    private func displayYouTube(videoId: String, isMute: Bool, shouldSavedHistory: Bool, videoSize: VideoSize, target: WallpaperDisplayTarget) {
        wallpaperWindowService.display(
            wallpaperKind: .youtube(videoId: videoId, isMute: isMute, videoSize: videoSize),
            target: target
        )

        if shouldSavedHistory {
            let youtubeWallpaper = YouTubeWallpaper(date: Date(), videoId: videoId, isMute: isMute, size: videoSize.rawValue)
            wallpaperHistoryService.store(youtubeWallpaper)
        }
    }
    
    private func displayWebPage(url: URL, arrowOperation: Bool, shouldSavedHistory: Bool, target: WallpaperDisplayTarget) {
        wallpaperWindowService.display(
            wallpaperKind: .web(url: url, arrowOperation: arrowOperation),
            target: target
        )

        if shouldSavedHistory {
            let webpageWallpaper = WebPageWallpaper(date: Date(), url: url, arrowOperation: arrowOperation)
            wallpaperHistoryService.store(webpageWallpaper)
        }
    }

    private func displayLocalVideo(request: VideoPlayRequest, shouldSavedHistory: Bool) {
        wallpaperWindowService.display(
            wallpaperKind: .video(url: request.url, mute: request.mute, videoSize: request.videoSize, backgroundColor: request.backgroundColor),
            target: request.target
        )

        if shouldSavedHistory {
            guard let latestVideoStore = applicationFileManager.getDirectory(.latestVideo) else { return }
            let storedFileUrl = latestVideoStore.appendingPathComponent("latest.\(request.url.pathExtension)")
            do {
                if fileManager.fileExists(atPath: storedFileUrl.path) {
                    try fileManager.removeItem(at: storedFileUrl)
                }
                try fileManager.copyItem(at: request.url, to: storedFileUrl)
                let localVideoWallpaper = LocalVideoWallpaper(
                    date: Date(),
                    url: storedFileUrl,
                    config: .init(
                        size: request.videoSize.rawValue,
                        isMute: request.mute,
                        backgroundColor: request.backgroundColor?.hex
                    )
                )
                wallpaperHistoryService.store(localVideoWallpaper)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    private func displayLatestWallpaper() {
        if let latestWallpaper = wallpaperHistoryService.fetchLatestWallpaper() {
            // TODO: will support multiple screens
//            wallpaperWindowService.display(wallpaperKind: latestWallpaper)
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
            settingWindowService.show()
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
