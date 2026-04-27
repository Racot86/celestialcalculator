import Foundation

nonisolated enum EclipticToEquatorial {
    /// (lambda, beta) in radians, ε in radians → (RA, Dec) in radians.
    static func convert(longitudeRad lambda: Double,
                        latitudeRad beta: Double,
                        obliquityRad eps: Double) -> EquatorialCoordinates {
        let sinDec = sin(beta) * cos(eps) + cos(beta) * sin(eps) * sin(lambda)
        let dec = asin(max(-1.0, min(1.0, sinDec)))
        let y = sin(lambda) * cos(eps) - tan(beta) * sin(eps)
        let x = cos(lambda)
        var ra = atan2(y, x)
        if ra < 0 { ra += 2.0 * .pi }
        return EquatorialCoordinates(rightAscension: ra, declination: dec)
    }
}
