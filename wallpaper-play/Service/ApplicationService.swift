import Foundation
import Injectable
import RealmSwift
import AppKit

protocol ApplicationService {
    func applicationDidFinishLaunching()
    func didTapWallPaperItem()
    func didTapPreferenceItem()
    func didTapOpenRealm()
    func dockMenu() -> NSMenu
}

class ApplicationServiceImpl: ApplicationService {
    
    private let realmService: RealmService
    private let notificationManager: NotificationManager
    private let wallpaperWindowManager: WallpaperWindowService
    private let videoFormWindowPresenter: VideoFormWindowPresenter
    private let wallpaperHistoryService: WallpaperHistoryService
    private let applicationFileManager: ApplicationFileManager
    private let fileManager: FileManager
    private let userSetting: UserSettingService
    private let appManager: AppManager
    private let dockMenuBuilder: DockMenuBuilder

    init(injector: Injectable) {
        realmService = injector.build()
        notificationManager = injector.build()
        wallpaperWindowManager = injector.build()
        videoFormWindowPresenter = injector.build()
        wallpaperHistoryService = injector.build()
        applicationFileManager = injector.build()
        userSetting = injector.build()
        appManager = injector.build()
        fileManager = .default
        dockMenuBuilder = injector.build()
    }
    
    func applicationDidFinishLaunching() {
        setUpRequestYouTubeNotification()
        setUpRequestVideoNotification()
        setUpRequestVisibilityIconNotification()
        setUpRequestWebPageNotification()
        setUpAppIcon()
        initWallpaper()
        openVideoFormIfNeeded()
    }

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
            guard let self = self, let url = param as? URL else { fatalError() }
            self.displayYouTube(url: url, shouldSavedHistory: true)
        }
    }
    
    private func setUpRequestWebPageNotification() {
        notificationManager.observe(name: .requestWebPage) { [weak self] param in
            guard let self = self, let url = param as? URL else { fatalError() }
            self.displayWebPage(url: url, shouldSavedHistory: true)
        }
    }
    
    private func displayYouTube(url: URL, shouldSavedHistory: Bool) {
        wallpaperWindowManager.display(display: .youtube(url: url))
        
        if shouldSavedHistory {
            let youtubeWallpaper = YouTubeWallpaper(date: Date(), url: url)
            wallpaperHistoryService.store(youtubeWallpaper)
        }
    }
    
    private func displayWebPage(url: URL, shouldSavedHistory: Bool) {
        wallpaperWindowManager.display(display: .web(url: url))
        
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
        wallpaperWindowManager.display(display: .video(value: value))
        
        if shouldSavedHistory {
            guard let latestVideoStore = applicationFileManager.getDirectory(.latestVideo) else { return }
            let latestVideoUrls = value.urls.map { url -> URL in
                let storedFileUrl = latestVideoStore.appendingPathComponent("latest.\(url.pathExtension)")
                do {
                    if fileManager.fileExists(atPath: storedFileUrl.path) {
                        try fileManager.removeItem(at: storedFileUrl)
                    }
                    try fileManager.copyItem(at: url, to: storedFileUrl)
                    return storedFileUrl
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
            
            let localVideoWallpaper = LocalVideoWallpaper(
                date: Date(),
                urls: latestVideoUrls,
                config: .init(size: value.videoSize.rawValue, isMute: value.mute)
            )
            wallpaperHistoryService.store(localVideoWallpaper)
        }
    }
    
    private func initWallpaper() {
        if let latestWallpaper = wallpaperHistoryService.fetchLatestWallpaper() {
            wallpaperWindowManager.display(display: latestWallpaper)
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
}
