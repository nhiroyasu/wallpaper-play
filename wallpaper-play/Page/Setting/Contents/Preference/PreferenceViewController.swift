import Cocoa

enum PreferenceCell {
    case launchAtLogin(viewData: SwitchCellViewData)
    case visibilityIcon(viewData: SwitchCellViewData)
    case openThisWindowAtFirst(viewData: SwitchCellViewData)
}

struct PreferenceViewData {
    let switchPreferences: [PreferenceCell]
}

struct PreferenceReloadData {
    let launchAtLogin: Bool
    let visibilityIcon: Bool
    let openThisWindowAtFirst: Bool
}

protocol PreferenceViewOutput: AnyObject {
    func reload(_ output: PreferenceReloadData)
}

class PreferenceViewController: NSViewController {
    
    private var viewData: PreferenceViewData = .init(
        switchPreferences: []
    )
    
    @IBOutlet weak var collectionView: NSCollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.collectionViewLayout = createLayout()
            collectionView.register(Type: SwitchCell.self)
        }
    }
    
    var presenter: PreferencePresenter

    init(presenter: PreferencePresenter) {
        self.presenter = presenter
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
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
                self?.presenter.didTapLaunchAtLogin(state: state)
            }
        case .visibilityIcon(let viewData):
            viewItem.set(viewData) { [weak self] state in
                self?.presenter.didTapVisibilityIcon(state: state)
            }
        case .openThisWindowAtFirst(let viewData):
            viewItem.set(viewData) { [weak self] state in
                self?.presenter.didTapOpenThisWindowAtFirst(state: state)
            }
        }
        return viewItem
    }
}

extension PreferenceViewController: PreferenceViewOutput {
    func reload(_ output: PreferenceReloadData) {
        let preferenceCellList: [PreferenceCell] = [
            .launchAtLogin(viewData: SwitchCellViewData(
                switchState: output.launchAtLogin,
                title: LocalizedString(key: .preference_launch_at_login_title),
                description: LocalizedString(key: .preference_launch_at_login_description)
            )),
            .visibilityIcon(viewData: SwitchCellViewData(
                switchState: output.visibilityIcon,
                title: LocalizedString(key: .preference_display_icon_title),
                description: LocalizedString(key: .preference_display_icon_description)
            )),
            .openThisWindowAtFirst(viewData: SwitchCellViewData(
                switchState: output.openThisWindowAtFirst,
                title: LocalizedString(key: .preference_open_window_title),
                description: LocalizedString(key: .preference_open_window_description)
            ))
        ]
        viewData = .init(switchPreferences: preferenceCellList)
        collectionView.reloadData()
    }
}
