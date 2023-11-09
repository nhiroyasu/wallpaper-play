import Foundation

enum SupportDirectory: String {
    case realm = "realm"
    case debugRealm = "debug-realm"
    case latestVideo = "latest-video"
    case latestThumb = "latest-thumb"
}

protocol ApplicationFileManager {
    /// ApplicationSupport下にあるdirNameディレクトリを取得する
    ///
    /// dirNameが存在し無い場合、新しく生成される
    func getDirectory(_ dirName: String) -> URL?
    /// ApplicationSupport下にあるdirNameディレクトリを取得する
    ///
    /// dirNameが存在し無い場合、新しく生成される
    func getDirectory(_ dir: SupportDirectory) -> URL?
    /// {applicationSupportPath}/filePath のファイルを取得する
    ///
    /// 存在し無い場合はnil
    func getFile(_ filePath: String) -> URL?
    /// {applicationSupportPath}/{dir}/fileName のファイルを取得する
    ///
    /// 存在し無い場合はnil
    func getFile(fileName: String, dir: SupportDirectory) -> URL?
}

class ApplicationFileManagerImpl: ApplicationFileManager {
    private let fileManager: FileManager
    
    init() {
        fileManager = .default
    }
    
    private func getApplicationSupportPath() throws -> URL {
        try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func getDirectory(_ dirName: String) -> URL? {
        do {
            let url = try getApplicationSupportPath().appendingPathComponent(dirName)
            if fileManager.fileExists(atPath: url.path) {
                return url
            } else {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
                return url
            }
        } catch {
            return nil
        }
    }
    
    func getDirectory(_ dir: SupportDirectory) -> URL? {
        getDirectory(dir.rawValue)
    }
    
    func getFile(_ filePath: String) -> URL? {
        do {
            let url = try getApplicationSupportPath().appendingPathComponent(filePath)
            if fileManager.fileExists(atPath: url.path) {
                return url
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func getFile(fileName: String, dir: SupportDirectory) -> URL? {
        getFile("\(dir.rawValue)/\(fileName)")
    }
}
