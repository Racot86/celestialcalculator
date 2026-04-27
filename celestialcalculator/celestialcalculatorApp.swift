import SwiftUI

@main
struct celestialcalculatorApp: App {
    init() {
        FontRegistration.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
