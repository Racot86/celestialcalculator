import Foundation

nonisolated enum HorizontalTransform {
    /// Convert apparent equatorial → topocentric horizontal.
    /// Azimuth measured from true North, eastward (navigational convention), 0–2π.
    static func horizontal(from eq: EquatorialCoordinates,
                           latitudeRad phi: Double,
                           localApparentSiderealTimeRad lst: Double) -> HorizontalCoordinates {
        let H = lst - eq.rightAscension                  // hour angle (radians)
        let dec = eq.declination
        let sinAlt = sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H)
        let alt = asin(max(-1.0, min(1.0, sinAlt)))
        // Azimuth from north (Meeus 13.6 gives from south; we convert to from-north).
        // Az_N = atan2(sin H, cos H sin φ - tan δ cos φ) measured from south, +west.
        // Use standard navigational form:
        let y = -cos(dec) * sin(H)
        let x = sin(dec) * cos(phi) - cos(dec) * sin(phi) * cos(H)
        var az = atan2(y, x)
        az = AngleMath.normalizeRadians(az)
        return HorizontalCoordinates(azimuth: az, altitude: alt)
    }
}
