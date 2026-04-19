import Foundation
import SwiftUI
import AppKit
import Injectable

enum PlaylistFormContext {
    case add
    case edit(playlist: Playlist)
}

@MainActor
protocol PlaylistFormTransitionDelegate: AnyObject {
    func dismiss()
}

@MainActor
protocol PlaylistFormViewModel: ObservableObject {
    var selectedFiles: [URL] { get }
    var playbackMode: PlaylistPlaybackMode { get set }
    var playlistName: String { get set }
    var videoSize: VideoSize { get set }
    var backgroundColor: Color { get set }
    var isMute: Bool { get set }
    var displayTargetTitles: [String] { get }
    var selectedDisplayTargetIndex: Int { get set }
    var canSave: Bool { get }
    var saveButtonTitle: String { get }
    var isPresentedAlert: Bool { get set }
    var alertMessage: String { get }
    var isPresentedIndicator: Bool { get }
    func pickVideoFiles()
    func moveSelectedFiles(fromOffsets: IndexSet, toOffset: Int)
    func removeSelectedFile(_ url: URL)
    func savePlaylist() async
    func didTapCloseButton()
}

class PlaylistFormViewModelImpl: PlaylistFormViewModel {
    @Published private(set) var selectedFiles: [URL] = []
    @Published var playbackMode: PlaylistPlaybackMode = .inOrder
    @Published var playlistName: String = ""
    @Published var videoSize: VideoSize = .aspectFill
    @Published var backgroundColor: Color = .white
    @Published var isMute: Bool = true
    @Published var selectedDisplayTargetIndex: Int = 0
    let displayTargetTitles: [String]
    @Published var isPresentedAlert: Bool = false
    @Published private(set) var alertMessage: String = ""
    @Published var isPresentedIndicator: Bool = false
    private let context: PlaylistFormContext
    private let displayTargetMenu: [DisplayTargetMenu]
    private let disconnectedDisplayTargetName: String?
    private let fileSelectionManager: any FileSelectionManager
    private let useCase: any PlaylistFormUseCase
    private let submitCompletion: (() -> Void)?
    weak var transitionDelegate: (any PlaylistFormTransitionDelegate)?

    init(
        injector: any Injectable,
        useCase: any PlaylistFormUseCase,
        context: PlaylistFormContext,
        submitCompletion: (() -> Void)?
    ) {
        self.context = context
        let displayTargetMenu: [DisplayTargetMenu] = [.allMonitors] + NSScreen.screens.map { .screen($0) }
        self.displayTargetMenu = displayTargetMenu
        self.disconnectedDisplayTargetName = Self.resolveDisconnectedDisplayTargetName(
            context: context,
            displayTargetMenu: displayTargetMenu
        )
        self.displayTargetTitles = Self.resolveDisplayTargetTitles(
            displayTargetMenu: displayTargetMenu,
            disconnectedDisplayTargetName: disconnectedDisplayTargetName
        )
        self.fileSelectionManager = injector.build()
        self.useCase = useCase
        self.submitCompletion = submitCompletion
        applyContextInitialValues()
    }

    var saveButtonTitle: String {
        switch context {
        case .add:
            return "Save"
        case .edit:
            return "Update"
        }
    }

    func pickVideoFiles() {
        let urls = fileSelectionManager.openMultiple(fileType: .movie)
        for url in urls {
            if selectedFiles.contains(url) {
                continue
            } else {
                selectedFiles.append(url)
            }
        }
    }

    func moveSelectedFiles(fromOffsets: IndexSet, toOffset: Int) {
        selectedFiles.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func removeSelectedFile(_ url: URL) {
        selectedFiles.removeAll { $0 == url }
    }

    var canSave: Bool {
        !playlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !selectedFiles.isEmpty
    }

    func savePlaylist() async {
        guard canSave else { return }

        isPresentedIndicator = true
        defer { isPresentedIndicator = false }
        do {
            switch context {
            case .add:
                try await useCase.createPlaylist(
                    name: playlistName,
                    playbackMode: playbackMode,
                    videoSize: videoSize,
                    backgroundColor: NSColor(backgroundColor).hex,
                    isMute: isMute,
                    target: convertToDisplayTarget(),
                    videoUrls: selectedFiles
                )
            case .edit(let playlist):
                try await useCase.updatePlaylist(
                    id: playlist.id,
                    name: playlistName,
                    playbackMode: playbackMode,
                    videoSize: videoSize,
                    backgroundColor: NSColor(backgroundColor).hex,
                    isMute: isMute,
                    target: convertToDisplayTarget(),
                    videoUrls: selectedFiles
                )
            }
            submitCompletion?()
            transitionDelegate?.dismiss()
        } catch {
            alertMessage = error.localizedDescription
            isPresentedAlert = true
        }
    }

    func didTapCloseButton() {
        transitionDelegate?.dismiss()
    }

    private func convertToDisplayTarget() -> WallpaperDisplayTarget {
        if displayTargetMenu.indices.contains(selectedDisplayTargetIndex) {
            switch displayTargetMenu[selectedDisplayTargetIndex] {
            case .allMonitors:
                return .sameOnAllMonitors
            case .screen(let nSScreen):
                return .specificMonitor(screen: ConnectedMonitorScreen(screen: nSScreen))
            }
        }

        if let disconnectedDisplayTargetName {
            return .specificMonitor(screen: SavedMonitorScreen(name: disconnectedDisplayTargetName))
        }

        return .sameOnAllMonitors
    }

    private func applyContextInitialValues() {
        guard case .edit(let playlist) = context else {
            return
        }

        selectedFiles = playlist.videos.map(\.url)
        playbackMode = playlist.playbackMode
        playlistName = playlist.name
        videoSize = playlist.videoSize
        backgroundColor = Color(NSColor(hex: playlist.backgroundColor))
        isMute = playlist.isMute
        selectedDisplayTargetIndex = resolveDisplayTargetIndex(target: playlist.target)
    }

    private func resolveDisplayTargetIndex(target: WallpaperDisplayTarget) -> Int {
        switch target {
        case .sameOnAllMonitors:
            return 0
        case .specificMonitor(let screen):
            if let displayTargetIndex = displayTargetMenu.firstIndex(where: { menu in
                switch menu {
                case .allMonitors:
                    return false
                case .screen(let nSScreen):
                    return nSScreen.localizedName == screen.name
                }
            }) {
                return displayTargetIndex
            }
            if disconnectedDisplayTargetName == screen.name {
                return displayTargetMenu.count
            }
            return 0
        }
    }

    private static func resolveDisconnectedDisplayTargetName(
        context: PlaylistFormContext,
        displayTargetMenu: [DisplayTargetMenu]
    ) -> String? {
        guard case .edit(let playlist) = context else {
            return nil
        }
        guard case .specificMonitor(let screen) = playlist.target else {
            return nil
        }
        let connectedScreenNames: Set<String> = Set(displayTargetMenu.compactMap { menu in
            switch menu {
            case .allMonitors:
                return nil
            case .screen(let nSScreen):
                return nSScreen.localizedName
            }
        })
        if connectedScreenNames.contains(screen.name) {
            return nil
        }
        return screen.name
    }

    private static func resolveDisplayTargetTitles(
        displayTargetMenu: [DisplayTargetMenu],
        disconnectedDisplayTargetName: String?
    ) -> [String] {
        var titles = displayTargetMenu.map(\.title)
        if let disconnectedDisplayTargetName {
            titles.append(disconnectedDisplayTargetName)
        }
        return titles
    }
}
