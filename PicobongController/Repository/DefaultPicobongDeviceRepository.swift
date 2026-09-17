import Foundation
import Combine

final class DefaultPicobongDeviceRepository: PicobongDeviceRepository {
    @Published private var devices: [PicobongDevice] = []
    @Published private var bluetoothState: String = "Initializing Bluetooth..."

    var devicesPublisher: Published<[PicobongDevice]>.Publisher { $devices }
    var bluetoothStatePublisher: Published<String>.Publisher { $bluetoothState }

    private let manager: PicobongBLEManager
    private var cancellables = Set<AnyCancellable>()

    init(manager: PicobongBLEManager = PicobongBLEManager()) {
        self.manager = manager

        manager.$devices
            .assign(to: &$devices)

        manager.$bluetoothStateDescription
            .assign(to: &$bluetoothState)
    }

    func startScanning() {
        manager.startScanning()
    }

    func stopScanning() {
        manager.stopScanning()
    }

    func connect(to deviceID: UUID) {
        manager.connect(to: deviceID)
    }

    func disconnect(from deviceID: UUID) {
        manager.disconnect(from: deviceID)
    }

    func setIntensity(_ intensity: Double, for deviceID: UUID) {
        manager.setIntensity(intensity, for: deviceID)
    }
}
