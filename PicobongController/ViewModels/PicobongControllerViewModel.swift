import Foundation
import Combine

final class PicobongControllerViewModel: ObservableObject {
    @Published private(set) var devices: [PicobongDevice] = []
    @Published private(set) var bluetoothStateDescription: String = "Initializing Bluetooth..."

    private let repository: PicobongDeviceRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: PicobongDeviceRepository = DefaultPicobongDeviceRepository()) {
        self.repository = repository

        repository.devicesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$devices)

        repository.bluetoothStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$bluetoothStateDescription)
    }

    func onAppear() {
        repository.startScanning()
    }

    func onDisappear() {
        repository.stopScanning()
    }

    func toggleConnection(for device: PicobongDevice) {
        switch device.connectionState {
        case .disconnected:
            repository.connect(to: device.id)
        case .connecting, .connected:
            repository.disconnect(from: device.id)
        }
    }

    func setIntensity(_ intensity: Double, for device: PicobongDevice) {
        repository.setIntensity(intensity, for: device.id)
    }

    func turnOff(_ device: PicobongDevice) {
        setIntensity(0.0, for: device)
    }
}
