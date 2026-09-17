import SwiftUI

@main
struct PicobongControllerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: PicobongControllerViewModel())
        }
    }
}
