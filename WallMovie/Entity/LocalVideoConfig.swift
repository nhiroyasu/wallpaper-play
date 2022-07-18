import Foundation
import RealmSwift

class LocalVideoConfig: EmbeddedObject {
    @Persisted var size: Int
    
    convenience init(
        size: Int
    ) {
        self.init()
        self.size = size
    }
}
