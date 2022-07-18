import Cocoa

struct SwitchCellViewData {
    let switchState: Bool
    let title: String
    let description: String?
}

class SwitchCell: NSCollectionViewItem {

    @IBOutlet weak var switchItem: NSSwitch!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    private var switchHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func set(_ viewData: SwitchCellViewData, switchHandler: @escaping (Bool) -> Void) {
        switchItem.state = viewData.switchState ? .on : .off
        titleLabel.stringValue = viewData.title
        if let description = viewData.description {
            descriptionLabel.isHidden = false
            descriptionLabel.stringValue = description
        } else {
            descriptionLabel.isHidden = true
        }
        self.switchHandler = switchHandler
    }
    
    @IBAction func didTapSwitchItem(_ sender: Any) {
        switchHandler?(switchItem.state == .on)
    }
}
