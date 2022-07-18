import Foundation
import AVKit

enum VideoSize: Int, CaseIterable {
    case aspectFill
    case aspectFit
    
    var videoGravity: AVLayerVideoGravity {
        switch self {
        case .aspectFill:
            return .resizeAspectFill
        case .aspectFit:
            return .resizeAspect
        }
    }
    
    var text: String {
        switch self {
        case .aspectFill:
            return "Aspect Fill"
        case .aspectFit:
            return "Aspect Fit"
        }
    }
}
