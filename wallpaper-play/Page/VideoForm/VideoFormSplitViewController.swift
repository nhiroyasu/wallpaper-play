import Cocoa
import Injectable

class VideoFormSplitViewController: NSSplitViewController {

    @IBOutlet weak var sidebarViewItem: NSSplitViewItem!
    @IBOutlet weak var contentViewItem: NSSplitViewItem!
    
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var horizontalConstraints: [NSLayoutConstraint] = []
    
    var localVideoSelectionViewController: LocalVideoSelectionViewController!
    var youtubeSelectionViewController: YouTubeSelectionViewController!
    var webpageSelectionViewController: WebPageSelectionViewController!
    var preferenceViewController: PreferenceViewController!
    lazy var notificationManager: NotificationManager = Injector.shared.build()

    override func viewDidLoad() {
        super.viewDidLoad()
        splitView.delegate = self
        
        notificationManager.observe(name: .selectedSideMenu) { [weak self] param in
            self?.handleSelectionChange(param as? SideMenuItem)
        }
        notificationManager.push(name: .selectedSideMenu, param: SideMenuItem.localVideo)
    }
    
    private var hasChildViewController: Bool {
        return !detailViewController.children.isEmpty
    }
    
    private var sidebarViewController: NSViewController {
        sidebarViewItem.viewController
    }
    
    private var detailViewController: NSViewController {
        contentViewItem.viewController
    }
    
    private func embedChildViewController(_ childViewController: NSViewController) {
        // This embeds a new child view controller.
        let currentDetailVC = detailViewController
        currentDetailVC.addChild(childViewController)
        currentDetailVC.view.addSubview(childViewController.view)
        
        // Build the horizontal, vertical constraints so that an added child view controller matches the width and height of its parent.
        let views = ["targetView": childViewController.view]
        horizontalConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[targetView]|",
                                           options: [],
                                           metrics: nil,
                                           views: views)
        NSLayoutConstraint.activate(horizontalConstraints)
        
        verticalConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[targetView]|",
                                           options: [],
                                           metrics: nil,
                                           views: views)
        NSLayoutConstraint.activate(verticalConstraints)
    }
    
    private func handleSelectionChange(_ sideMenuItem: SideMenuItem?) {
        let currentDetailVC = detailViewController
        
        // Let the outline view controller handle the selection (helps you decide which detail view to use).
        if let vcForDetail = getViewController(for: sideMenuItem) {
            if hasChildViewController && currentDetailVC.children[0] != vcForDetail {
                /** The incoming child view controller is different from the one you currently have,
                    so remove the old one and add the new one.
                */
                currentDetailVC.removeChild(at: 0)
                // Remove the old child detail view.
                detailViewController.view.subviews[0].removeFromSuperview()
                // Add the new child detail view.
                embedChildViewController(vcForDetail)
            } else {
                if !hasChildViewController {
                    // You don't have a child view controller, so embed the new one.
                    embedChildViewController(vcForDetail)
                }
            }
        } else {
            // No selection. You don't have a child view controller to embed, so remove the current child view controller.
            if hasChildViewController {
                currentDetailVC.removeChild(at: 0)
                detailViewController.view.subviews[0].removeFromSuperview()
            }
        }
    }
    
    private func getViewController(for selectedItem: SideMenuItem?) -> NSViewController? {
        switch selectedItem {
        case .localVideo:
            return localVideoSelectionViewController
        case .youtube:
            return youtubeSelectionViewController
        case .webpage:
            return webpageSelectionViewController
        case .preference:
            return preferenceViewController
        case .none:
            return nil
        }
    }
    
    override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        false
    }
}
