import Foundation
import SwiftUI
import AppKit
import Injectable

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
    @Published var isPresentedAlert: Bool = false
    @Published private(set) var alertMessage: String = ""
    @Published var isPresentedIndicator: Bool = false
    private let displayTargetMenu: [DisplayTargetMenu]
    private let fileSelectionManager: any FileSelectionManager
    private let useCase: any PlaylistFormUseCase
    private let submitCompletion: (() -> Void)?
    weak var transitionDelegate: (any PlaylistFormTransitionDelegate)?

    init(
        injector: any Injectable,
        useCase: any PlaylistFormUseCase,
        submitCompletion: (() -> Void)?
    ) {
        self.displayTargetMenu = [.allMonitors] + NSScreen.screens.map { .screen($0) }
        self.fileSelectionManager = injector.build()
        self.useCase = useCase
        self.submitCompletion = submitCompletion
    }

    var displayTargetTitles: [String] {
        displayTargetMenu.map(\.title)
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
            try await useCase.savePlaylist(
                name: playlistName,
                playbackMode: playbackMode,
                videoSize: videoSize,
                backgroundColor: NSColor(backgroundColor).hex,
                isMute: isMute,
                target: convertToDisplayTarget(),
                videoUrls: selectedFiles
            )
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
        guard displayTargetMenu.indices.contains(selectedDisplayTargetIndex) else {
            return .sameOnAllMonitors
        }

        switch displayTargetMenu[selectedDisplayTargetIndex] {
        case .allMonitors:
            return .sameOnAllMonitors
        case .screen(let nSScreen):
            return .specificMonitor(screen: ConnectedMonitorScreen(screen: nSScreen))
        }
    }
}
