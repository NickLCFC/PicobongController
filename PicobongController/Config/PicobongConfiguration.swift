import Foundation
import CoreBluetooth

struct PicobongConfiguration {
    private struct ConfigFile: Decodable {
        let `protocol`: String
        let connectionType: String
        let serviceUUID: String
        let txCharacteristicUUID: String
        let deviceNames: [String]

        enum CodingKeys: String, CodingKey {
            case `protocol`
            case connectionType = "connection_type"
            case serviceUUID = "service_uuid"
            case txCharacteristicUUID = "tx_characteristic_uuid"
            case deviceNames = "device_names"
        }
    }

    private static let fallback = ConfigFile(
        protocol: "picobong",
        connectionType: "ble",
        serviceUUID: "0000fff0-0000-1000-8000-00805f9b34fb",
        txCharacteristicUUID: "0000fff1-0000-1000-8000-00805f9b34fb",
        deviceNames: [
            "Blow hole",
            "Diver",
            "Picobong Egg",
            "Life guard",
            "Picobong Ring",
            "Surfer",
            "Picobong Butt Plug",
            "Egg driver",
            "Surfer_plug"
        ]
    )

    private static let resolvedConfig: ConfigFile = {
        guard let url = Bundle.main.url(forResource: "picobong-device-config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(ConfigFile.self, from: data) else {
            return fallback
        }
        return decoded
    }()

    static let protocolName = resolvedConfig.protocol
    static let connectionType = resolvedConfig.connectionType
    static let deviceNames = Set(resolvedConfig.deviceNames)
    static let serviceUUID = CBUUID(string: resolvedConfig.serviceUUID)
    static let txCharacteristicUUID = CBUUID(string: resolvedConfig.txCharacteristicUUID)

    static func isSupported(name: String?) -> Bool {
        guard let name else { return false }
        return deviceNames.contains(name)
    }
}
