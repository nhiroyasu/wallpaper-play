import AppKit
import UniformTypeIdentifiers

enum FileType {
    case image
    case movie
    case none

    var contentTypes: [UTType] {
        switch self {
        case .image:
            return [.image]
        case .movie:
            return [.movie, .video, .mpeg4Movie, .quickTimeMovie]
        case .none:
            return []
        }
    }
}

protocol FileSelectionManager {
    func open(fileType: FileType) -> URL?
    func openMultiple(fileType: FileType) -> [URL]
}

class FileSelectionManagerImpl: FileSelectionManager {
    func open(fileType: FileType) -> URL? {
        let openPanel = NSOpenPanel()
        // TODO: 多言語対応
        openPanel.title = "Select Movie"
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = fileType.contentTypes
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            return openPanel.url
        } else {
            return nil
        }
    }

    func openMultiple(fileType: FileType) -> [URL] {
        let openPanel = NSOpenPanel()
        // TODO: 多言語対応
        openPanel.title = "Select Movie"
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = true
        openPanel.allowedContentTypes = fileType.contentTypes
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            return openPanel.urls
        } else {
            return []
        }
    }
}
