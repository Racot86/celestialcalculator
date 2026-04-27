import Foundation
import Observation

struct ChartBody: Identifiable, Hashable {
    let bodyID: CelestialBodyID
    let displayName: String
    let symbol: String
    let azimuthDeg: Double
    let altitudeDeg: Double
    var id: String { bodyID.id }
}

@Observable
final class ChartViewModel {
    var observerStore: ObserverStore
    /// Window's left edge azimuth in degrees [0, 360). The window spans 90°.
    var windowStartDeg: Double = 0

    /// User-controlled pan step.
    let stepDeg: Double = 10
    /// Visible window width in degrees.
    let windowWidthDeg: Double = 90

    init(observerStore: ObserverStore) {
        self.observerStore = observerStore
    }

    var visibleBodies: [ChartBody] {
        var ids: [CelestialBodyID] = [.sun, .moon]
        ids += PlanetKind.allCases.map { .planet($0) }
        ids += (0..<NavigationalStars.count).map { .star($0) }
        let observer = observerStore.observer
        return ids.compactMap { id in
            let h = BodyFactory.body(for: id).horizontalCoordinates(for: observer)
            guard h.altitudeDegrees > 0 else { return nil }
            return ChartBody(bodyID: id,
                             displayName: id.displayName,
                             symbol: id.symbol,
                             azimuthDeg: h.azimuthDegrees,
                             altitudeDeg: h.altitudeDegrees)
        }
    }

    /// Bodies whose azimuth falls inside the current 90° window. Each entry's
    /// `relX` is its x-coordinate inside the window in [0, 1].
    func bodiesInWindow() -> [(body: ChartBody, relX: Double)] {
        let start = windowStartDeg
        let width = windowWidthDeg
        return visibleBodies.compactMap { body in
            var d = body.azimuthDeg - start
            d = ((d.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
            if d > width { return nil }
            return (body, d / width)
        }
    }

    func step(_ direction: Int) {
        let delta = Double(direction) * stepDeg
        var s = windowStartDeg + delta
        s = ((s.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
        windowStartDeg = s
    }

    func centerOnBrightest() {
        guard let brightest = visibleBodies.max(by: { $0.altitudeDeg < $1.altitudeDeg }) else { return }
        var s = brightest.azimuthDeg - windowWidthDeg / 2
        s = ((s.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
        // Snap to step grid.
        s = (s / stepDeg).rounded() * stepDeg
        windowStartDeg = s
    }
}
