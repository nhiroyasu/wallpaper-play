import AppKit

enum FileType {
    case image
    case movie
    case none
    
    var extensionList: [String] {
        switch self {
        case .image:
            return ["jpg", "jpeg", "JPG", "JPEG", "png", "PNG", "tiff", "TIFF", "tif", "TIF"]
        case .movie:
            return ["mp4", "mov"]
        case .none:
            return []
        }
    }
}

protocol FileSelectionManager {
    func open(fileType: FileType) -> URL?
}

class FileSelectionManagerImpl: FileSelectionManager {
    func open(fileType: FileType) -> URL? {
        let openPanel = NSOpenPanel()
        // TODO: 多言語対応
        openPanel.title = "Select Movie"
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = fileType.extensionList
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            return openPanel.url
        } else {
            return nil
        }
    }
}
