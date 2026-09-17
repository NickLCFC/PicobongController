import Foundation
import CoreBluetooth

final class PicobongBLEManager: NSObject, ObservableObject {
    @Published private(set) var devices: [PicobongDevice] = []
    @Published private(set) var bluetoothStateDescription: String = "Initializing Bluetooth..."

    private lazy var centralManager = CBCentralManager(delegate: self, queue: .main)
    private var peripheralsByID: [UUID: CBPeripheral] = [:]
    private var txCharacteristicByPeripheralID: [UUID: CBCharacteristic] = [:]

    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [PicobongConfiguration.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func stopScanning() {
        centralManager.stopScan()
    }

    func connect(to deviceID: UUID) {
        guard let peripheral = peripheralsByID[deviceID] else { return }
        updateDevice(deviceID: deviceID) { $0.connectionState = .connecting }
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect(from deviceID: UUID) {
        guard let peripheral = peripheralsByID[deviceID] else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func setIntensity(_ intensity: Double, for deviceID: UUID) {
        guard let peripheral = peripheralsByID[deviceID],
              let txCharacteristic = txCharacteristicByPeripheralID[deviceID],
              peripheral.state == .connected else {
            return
        }

        let clamped = max(0.0, min(1.0, intensity))
        let value = UInt8((clamped * 255.0).rounded())
        let data = Data([value])
        peripheral.writeValue(data, for: txCharacteristic, type: .withResponse)
        updateDevice(deviceID: deviceID) { $0.intensity = clamped }
    }

    private func upsertDevice(id: UUID, name: String) {
        if let index = devices.firstIndex(where: { $0.id == id }) {
            devices[index].name = name
        } else {
            devices.append(PicobongDevice(id: id, name: name))
            devices.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }

    private func updateDevice(deviceID: UUID, mutate: (inout PicobongDevice) -> Void) {
        guard let index = devices.firstIndex(where: { $0.id == deviceID }) else { return }
        mutate(&devices[index])
    }

    private func setConnectionState(_ state: PicobongConnectionState, for peripheral: CBPeripheral) {
        updateDevice(deviceID: peripheral.identifier) {
            $0.connectionState = state
            if state != .connected {
                $0.intensity = 0.0
            }
        }
    }

    private func discoverTxCharacteristic(for peripheral: CBPeripheral) {
        peripheral.services?.forEach { service in
            if service.uuid == PicobongConfiguration.serviceUUID {
                peripheral.discoverCharacteristics([PicobongConfiguration.txCharacteristicUUID], for: service)
            }
        }
    }
}

extension PicobongBLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothStateDescription = "Bluetooth is on"
        case .poweredOff:
            bluetoothStateDescription = "Bluetooth is off"
            devices.removeAll()
        case .unauthorized:
            bluetoothStateDescription = "Bluetooth access unauthorized"
        case .unsupported:
            bluetoothStateDescription = "Bluetooth unsupported on this device"
        case .resetting:
            bluetoothStateDescription = "Bluetooth is resetting"
        case .unknown:
            bluetoothStateDescription = "Bluetooth state unknown"
        @unknown default:
            bluetoothStateDescription = "Unknown Bluetooth state"
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let candidateName = peripheral.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String)

        guard PicobongConfiguration.isSupported(name: candidateName) else {
            return
        }

        let deviceName = candidateName ?? "Unknown Picobong Device"
        peripheralsByID[peripheral.identifier] = peripheral
        peripheral.delegate = self
        upsertDevice(id: peripheral.identifier, name: deviceName)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        setConnectionState(.connected, for: peripheral)
        peripheral.discoverServices([PicobongConfiguration.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        setConnectionState(.disconnected, for: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        txCharacteristicByPeripheralID[peripheral.identifier] = nil
        setConnectionState(.disconnected, for: peripheral)
    }
}

extension PicobongBLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        discoverTxCharacteristic(for: peripheral)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil,
              let characteristics = service.characteristics else {
            return
        }

        if let txCharacteristic = characteristics.first(where: { $0.uuid == PicobongConfiguration.txCharacteristicUUID }) {
            txCharacteristicByPeripheralID[peripheral.identifier] = txCharacteristic
        }
    }
}
