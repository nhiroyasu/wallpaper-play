import Cocoa

extension NSCollectionView {
    
    func register(Type: Any.Type) {
        self.register(NSNib(nibNamed: String(describing: Type), bundle: nil), forItemWithIdentifier: .init(rawValue: String(describing: Type)))
    }
    
    func dequeueItem<T: NSCollectionViewItem>(Type: T.Type, for indexPath: IndexPath) -> T {
        self.makeItem(withIdentifier: .init(rawValue: String(describing: Type)), for: indexPath) as! T
    }
}
