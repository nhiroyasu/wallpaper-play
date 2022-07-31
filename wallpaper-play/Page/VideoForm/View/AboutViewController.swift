import Cocoa
import SwiftUI

class AboutViewController: NSViewController {
    @IBOutlet weak var stackView: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = NSHostingController(rootView: AboutView())
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChild(vc)
        stackView.addView(vc.view, in: .center)
        
    }
}

class SelfSizingHostingController<Content>: NSHostingController<Content> where Content: View {

}

