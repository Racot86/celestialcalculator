import Foundation

enum Refraction {
    /// Bennett's formula. Input/output altitudes in radians.
    /// Returns refraction-corrected (apparent) altitude.
    static func apparentAltitude(trueAltitudeRad: Double,
                                 pressureHPa: Double = 1010,
                                 temperatureC: Double = 10) -> Double {
        let h = AngleMath.radToDeg(trueAltitudeRad)
        // Saemundsson's formula for true → apparent
        let arg = (h + 10.3 / (h + 5.11)) * .pi / 180.0
        var R = 1.02 / tan(arg) // arcminutes
        R *= (pressureHPa / 1010.0) * (283.0 / (273.0 + temperatureC))
        return trueAltitudeRad + AngleMath.degToRad(R / 60.0)
    }
}
