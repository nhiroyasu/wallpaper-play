import Foundation
import RealmSwift

class LocalVideoConfig: EmbeddedObject {
    @Persisted var size: Int
    @Persisted var isMute: Bool = true
    
    convenience init(
        size: Int,
        isMute: Bool
    ) {
        self.init()
        self.size = size
        self.isMute = isMute
    }
}
