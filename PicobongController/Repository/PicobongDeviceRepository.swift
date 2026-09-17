import Foundation
import Combine

protocol PicobongDeviceRepository {
    var devicesPublisher: Published<[PicobongDevice]>.Publisher { get }
    var bluetoothStatePublisher: Published<String>.Publisher { get }

    func startScanning()
    func stopScanning()
    func connect(to deviceID: UUID)
    func disconnect(from deviceID: UUID)
    func setIntensity(_ intensity: Double, for deviceID: UUID)
}
