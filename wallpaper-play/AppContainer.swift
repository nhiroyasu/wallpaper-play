import Foundation
import Swinject
import Injectable

class AppContainer {
    static func build() -> Container {
        let container = Container()

        // MARK: - empty dependencies

        container.register((any UrlValidationService).self) { _ in UrlValidationServiceImpl() }
        container.register((any AppManager).self) { _ in AppManagerImpl() }
        container.register((any ApplicationFileManager).self) { _ in ApplicationFileManagerImpl() }
        container.register((any SystemWallpaperService).self) { _ in SystemWallpaperServiceImpl()}
        container.register((any AlertManager).self) { _ in AlertManagerImpl()}
        container.register((any URLResolverService).self) { _ in URLResolverServiceImpl()}
        container.register((any NotificationManager).self) { _ in NotificationManagerImpl()}
        container.register((any YouTubeContentsService).self) { _ in YouTubeContentsServiceImpl()}
        container.register((any FileSelectionManager).self) { _ in FileSelectionManagerImpl()}
        container.register((any AVPlayerManager).self) { _ in AVPlayerManagerImpl()}
        container.register((any SettingWindowService).self) { injector in SettingWindowServiceImpl() }

        // MARK: - DockMenu
        container.register((any DockMenuUseCase).self) { injector in DockMenuInteractor(injector: injector) }
        container.register((any DockMenuAction).self) { injector in DockMenuActionImpl(injector: injector)}
        container.register((any DockMenuItemBuilder).self) { injector in DockMenuItemBuilderImpl(injector: injector) }
        container.register((any DockMenuBuilder).self) { injector in DockMenuBuilderImpl(injector: injector) }

        // MARK: - some dependencies

        container.register((any WallpaperRequestService).self) { injector in WallpaperRequestServiceImpl(injector: injector) }
        container.register((any RealmMigrationService).self) { injector in RealmMigrationServiceImpl(injector: injector) }
        container.register((any RealmService).self) { injector in RealmManagerImpl(injector: injector) }
        container.register((any UserSettingService).self) { _ in UserSettingServiceImpl(userDefaults: UserDefaults.standard) }.inObjectScope(.container)
        container.register((any WallpaperWindowService).self) { injector in WallpaperWindowServiceImpl(injector: injector) }
        container.register((any WallpaperHistoryService).self) { injector in WallpaperHistoryServiceImpl(injector: injector) }
        container.register((any ApplicationService).self) { injector in ApplicationServiceImpl(injector: injector) }

        return container
    }
}

extension Injector {
    static let shared = Injector(container: AppContainer.build())
}
