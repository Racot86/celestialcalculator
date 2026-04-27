import Foundation

nonisolated struct HorizontalCoordinates: Equatable {
    var azimuth: Double
    var altitude: Double

    var azimuthDegrees: Double { azimuth * 180.0 / .pi }
    var altitudeDegrees: Double { altitude * 180.0 / .pi }

    var isAboveHorizon: Bool { altitude > 0 }
}
