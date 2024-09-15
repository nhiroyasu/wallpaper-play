import Foundation
import RealmSwift

class LocalVideoConfig: EmbeddedObject {
    @Persisted var size: Int
    @Persisted var isMute: Bool = true
    // NOTE: Added at a realm schema version 6.
    @Persisted var backgroundColor: ColorHex?

    convenience init(
        size: Int,
        isMute: Bool,
        backgroundColor: ColorHex?
    ) {
        self.init()
        self.size = size
        self.isMute = isMute
        self.backgroundColor = backgroundColor
    }
}
