import Foundation

struct EquatorialCoordinates: Equatable {
    var rightAscension: Double
    var declination: Double
    var distanceAU: Double?

    static func from(rightAscensionHours: Double, declinationDegrees: Double, distanceAU: Double? = nil) -> EquatorialCoordinates {
        EquatorialCoordinates(
            rightAscension: rightAscensionHours * 15.0 * .pi / 180.0,
            declination: declinationDegrees * .pi / 180.0,
            distanceAU: distanceAU
        )
    }
}
