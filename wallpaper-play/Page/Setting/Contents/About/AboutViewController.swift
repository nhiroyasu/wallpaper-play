import Cocoa
import SwiftUI
import Injectable

class AboutViewController: NSViewController {
    @IBOutlet weak var stackView: NSStackView!
    private let appManager: any AppManager

    required init?(coder: NSCoder) {
        fatalError()
    }

    init(injector: any Injectable) {
        self.appManager = injector.build()
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = NSHostingController(rootView: AboutView())
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChild(vc)
        stackView.addView(vc.view, in: .center)
        
    }
}
