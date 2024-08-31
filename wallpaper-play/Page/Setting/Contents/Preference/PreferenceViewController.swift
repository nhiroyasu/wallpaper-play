import Cocoa

enum PreferenceCell {
    case launchAtLogin(viewData: SwitchCellViewData)
    case visibilityIcon(viewData: SwitchCellViewData)
    case openThisWindowAtFirst(viewData: SwitchCellViewData)
}

struct PreferenceViewData {
    let switchPreferences: [PreferenceCell]
}

class PreferenceViewController: NSViewController {
    
    var viewData: PreferenceViewData = .init(
        switchPreferences: []
    )
    
    @IBOutlet weak var collectionView: NSCollectionView! {
        didSet {
            collectionView.dataSource = self
//            collectionView.delegate = self
            collectionView.collectionViewLayout = createLayout()
            collectionView.register(Type: SwitchCell.self)
        }
    }
    
    var action: PreferenceAction
    
    init(action: PreferenceAction) {
        self.action = action
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        action.viewDidLoad()
    }
    
    func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(64.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension PreferenceViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        viewData.switchPreferences.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let viewItem = collectionView.dequeueItem(Type: SwitchCell.self, for: indexPath)
        let preferenceCell = viewData.switchPreferences[indexPath.item]
        switch preferenceCell {
        case .launchAtLogin(let viewData):
            viewItem.set(viewData) { [weak self] state in
                self?.action.didTapLaunchAtLogin(state: state)
            }
        case .visibilityIcon(let viewData):
            viewItem.set(viewData) { [weak self] state in
                self?.action.didTapVisibilityIcon(state: state)
            }
        case .openThisWindowAtFirst(let viewData):
            viewItem.set(viewData) { [weak self] state in
                self?.action.didTapOpenThisWindowAtFirst(state: state)
            }
        }
        return viewItem
    }
}
