import Foundation
import Combine

extension Notification.Name {
    static let requestYouTube = Notification.Name("requestYouTube")
    static let requestVideo = Notification.Name("requestVideo")
    static let requestWebPage = Notification.Name("requestWebPage")
    static let requestCamera = Notification.Name("requestCamera")
    static let selectedSideMenu = Notification.Name("selectedSideBar")
    static let requestVisibilityIcon = Notification.Name("requestVisibilityIcon")
}

/// @mockable
protocol NotificationManager {
    func push(name: Notification.Name, param: Any?)
    func observe(name: Notification.Name, handler: @escaping (Any?) -> Void)
    func publisher(for name: Notification.Name) -> AnyPublisher<Any?, Never>
}

class NotificationManagerImpl: NotificationManager {
    func push(name: Notification.Name, param: Any?) {
        if let param = param {
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["param": param])
        } else {
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    func observe(name: Notification.Name, handler: @escaping (Any?) -> Void) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            let param = notification.userInfo?["param"]
            handler(param)
        }
    }

    func publisher(for name: Notification.Name) -> AnyPublisher<Any?, Never> {
        NotificationCenter.default.publisher(for: name)
            .map { notification in
                notification.userInfo?["param"]
            }
            .eraseToAnyPublisher()
    }
}

struct NotificationRequestVideoTDO {
    let videoId: String
    let isMute: Bool
}
