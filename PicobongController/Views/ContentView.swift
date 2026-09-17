import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: PicobongControllerViewModel

    init(viewModel: PicobongControllerViewModel = PicobongControllerViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Bluetooth")) {
                    Text(viewModel.bluetoothStateDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Picobong Devices")) {
                    if viewModel.devices.isEmpty {
                        Text("No supported devices found yet.")
                            .foregroundColor(.secondary)
                    }

                    ForEach(viewModel.devices) { device in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(device.name)
                                        .font(.headline)
                                    Text(statusText(for: device.connectionState))
                                        .font(.caption)
                                        .foregroundColor(statusColor(for: device.connectionState))
                                }

                                Spacer()

                                Button(action: { viewModel.toggleConnection(for: device) }) {
                                    Text(buttonText(for: device.connectionState))
                                        .font(.subheadline.bold())
                                }
                                .buttonStyle(DefaultButtonStyle())
                            }

                            if device.connectionState == .connected {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Intensity")
                                        Spacer()
                                        Text("\(Int((device.intensity * 100).rounded()))%")
                                            .foregroundColor(.secondary)
                                    }

                                    Slider(
                                        value: Binding(
                                            get: { device.intensity },
                                            set: { viewModel.setIntensity($0, for: device) }
                                        ),
                                        in: 0...1
                                    )

                                    Button("Turn Off") {
                                        viewModel.turnOff(device)
                                    }
                                    .buttonStyle(DefaultButtonStyle())
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Picobong Controller")
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
    }

    private func statusText(for state: PicobongConnectionState) -> String {
        switch state {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        }
    }

    private func statusColor(for state: PicobongConnectionState) -> Color {
        switch state {
        case .disconnected:
            return .secondary
        case .connecting:
            return .orange
        case .connected:
            return .green
        }
    }

    private func buttonText(for state: PicobongConnectionState) -> String {
        switch state {
        case .disconnected:
            return "Connect"
        case .connecting, .connected:
            return "Disconnect"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: PicobongControllerViewModel())
    }
}
