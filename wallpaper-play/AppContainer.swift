import Foundation
import Swinject
import Injectable

class AppContainer {
    
    static func build() -> Container {
        let container = Container()
        container.register(UrlValidationService.self) { _ in UrlValidationServiceImpl() }
        container.register(AppManager.self) { _ in AppManagerImpl() }
        container.register(ApplicationFileManager.self) { _ in ApplicationFileManagerImpl() }
        container.register(SystemWallpaperService.self) { _ in SystemWallpaperServiceImpl()}
        container.register(AlertManager.self) { _ in AlertManagerImpl()}
        container.register(URLResolverService.self) { _ in URLResolverServiceImpl()}
        container.register(NotificationManager.self) { _ in NotificationManagerImpl()}
        container.register(UserSettingService.self) { _ in UserSettingServiceImpl(userDefaults: UserDefaults.standard) }.inObjectScope(.container)
        container.register(YouTubeContentsService.self) { _ in YouTubeContentsServiceImpl()}
        container.register(FileSelectionManager.self) { _ in FileSelectionManagerImpl()}
        container.register(AVPlayerManager.self) { _ in AVPlayerManagerImpl()}
        container.register(ApplicationService.self) { injector in ApplicationServiceImpl(injector: injector) }
        container.register(WallpaperWindowService.self) { injector in WallpaperWindowServiceImpl(injector: injector) }
        container.register(WallpaperHistoryService.self) { injector in WallpaperHistoryServiceImpl(injector: injector) }
        container.register(RealmService.self) { injector in RealmManagerImpl(injector: injector) }
        return container
    }
}

extension Injector {
    static let shared = Injector(container: AppContainer.build())
}
