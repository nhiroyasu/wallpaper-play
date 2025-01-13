import AVFoundation

protocol CameraDeviceService {
    func fetchDevices() -> [AVCaptureDevice]
    func fetchDevice(deviceId: String) -> AVCaptureDevice?
}

class CameraDeviceServiceImpl: CameraDeviceService {
    func fetchDevices() -> [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
            mediaType: .video,
            position: .unspecified
        ).devices
    }

    func fetchDevice(deviceId: String) -> AVCaptureDevice? {
        fetchDevices().first { $0.uniqueID == deviceId }
    }
}
