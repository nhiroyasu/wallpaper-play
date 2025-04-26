import Foundation
import RealmSwift

extension URL: FailableCustomPersistable {
    public init?(persistedValue: String) {
        self.init(string: persistedValue)
    }
    
    public var persistableValue: String {
        self.absoluteString
    }
    
    public typealias PersistedType = String
}
