import Foundation
import AppKit

extension NSNib.Name {
    
    static let windowController = WindowController()
    
    struct WindowController {
        let wallMovie = String(describing: WallMovieWindowController.self)
        let videForm = String(describing: VideoFormWindowController.self)
    }
}
