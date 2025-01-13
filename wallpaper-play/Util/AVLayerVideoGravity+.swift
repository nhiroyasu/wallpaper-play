import AVFoundation

extension  AVLayerVideoGravity {
    static func from(_ videoSize: VideoSize) -> AVLayerVideoGravity {
        switch videoSize {
        case .aspectFill:
            return .resizeAspectFill
        case .aspectFit:
            return .resizeAspect
        }
    }
}
