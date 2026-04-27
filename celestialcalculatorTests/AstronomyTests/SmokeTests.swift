import Testing
import Foundation
@testable import celestialcalculator

/// End-to-end smoke tests: every body produces a finite az/alt.
struct SmokeTests {
    @Test func allBodiesProduceFiniteAzimuth() {
        let observer = Observer(date: Date(), latitude: 40.7128, longitude: -74.0060)
        var ids: [CelestialBodyID] = [.sun, .moon]
        ids += PlanetKind.allCases.map { .planet($0) }
        ids += (0..<NavigationalStars.count).map { .star($0) }
        for id in ids {
            let h = BodyFactory.body(for: id).horizontalCoordinates(for: observer)
            #expect(h.azimuthDegrees.isFinite)
            #expect((0...360).contains(h.azimuthDegrees) || abs(h.azimuthDegrees - 360.0) < 1e-9)
            #expect((-90...90).contains(h.altitudeDegrees))
        }
    }
}
