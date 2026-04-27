import SwiftUI

struct BodyPickerView: View {
    @Binding var selection: CelestialBodyID

    private static let allIDs: [CelestialBodyID] = {
        var ids: [CelestialBodyID] = [.sun, .moon]
        ids += PlanetKind.allCases.map { .planet($0) }
        ids += (0..<NavigationalStars.count).map { .star($0) }
        return ids
    }()

    var body: some View {
        Picker("Body", selection: $selection) {
            ForEach(Self.allIDs, id: \.id) { id in
                Text(id.displayName).tag(id)
            }
        }
        .pickerStyle(.menu)
        .tint(BrutalistTheme.accent)
    }
}
