import Foundation

enum PlaylistPlaybackMode: Int, CaseIterable {
    case inOrder = 0
    case shuffle = 1

    var title: String {
        switch self {
        case .inOrder:
            return "In Order"
        case .shuffle:
            return "Shuffle"
        }
    }
}
