import Foundation

enum PicobongConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
}

struct PicobongDevice: Identifiable, Equatable {
    let id: UUID
    var name: String
    var connectionState: PicobongConnectionState
    var intensity: Double

    init(id: UUID, name: String, connectionState: PicobongConnectionState = .disconnected, intensity: Double = 0.0) {
        self.id = id
        self.name = name
        self.connectionState = connectionState
        self.intensity = intensity
    }
}
