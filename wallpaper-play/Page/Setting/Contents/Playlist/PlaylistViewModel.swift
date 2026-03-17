import Foundation

@MainActor
protocol PlaylistTransitionDelegate: AnyObject {
    func transitionToPlaylistForm(submitCompletion: (() -> Void)?)
}

@MainActor
protocol PlaylistViewModel: ObservableObject {
    var playlists: [Playlist] { get }
    var isPresentedAlert: Bool { get set }
    var alertMessage: String { get }
    func fetchPlaylists()
    func deletePlaylist(id: UUID) async
    func didTapAddPlaylistButton()
    func didTapPlayPlaylistButton(id: UUID)
}

class PlaylistViewModelImpl: PlaylistViewModel {
    @Published private(set) var playlists: [Playlist] = []
    @Published var isPresentedAlert: Bool = false
    @Published private(set) var alertMessage: String = ""
    private let useCase: any PlaylistUseCase
    weak var transitionDelegate: (any PlaylistTransitionDelegate)?

    init(useCase: any PlaylistUseCase) {
        self.useCase = useCase
    }

    func fetchPlaylists() {
        playlists = useCase.fetchPlaylists()
    }

    func deletePlaylist(id: UUID) async {
        do {
            try await useCase.deletePlaylist(id: id)
            playlists = useCase.fetchPlaylists()
        } catch {
            alertMessage = error.localizedDescription
            isPresentedAlert = true
        }
    }

    func didTapAddPlaylistButton() {
        transitionDelegate?.transitionToPlaylistForm { [weak self] in
            self?.fetchPlaylists()
        }
    }

    func didTapPlayPlaylistButton(id: UUID) {
        useCase.playPlaylist(id: id)
    }
}
