import Foundation

/// One hour-row in the almanac's daily table.
struct AlmanacHourRow: Identifiable, Sendable {
    var id: Int { hour }
    let hour: Int
    let ghaAriesDeg: Double
    let sun: BodyHourly
    let venus: BodyHourly
    let mars: BodyHourly
    let jupiter: BodyHourly
    let saturn: BodyHourly
    let moon: BodyHourly
}

/// Per-body hourly data block as seen in the Nautical Almanac columns.
struct BodyHourly: Sendable {
    let ghaDeg: Double
    let decDeg: Double
    let vMinPerHour: Double?
    let dMinPerHour: Double
    let sdMin: Double?
    let hpMin: Double?
}

struct AlmanacStarRow: Identifiable, Sendable {
    var id: String { name }
    let name: String
    let bayer: String
    let magnitude: Double
    let shaDeg: Double
    let decDeg: Double
}

/// Phenomena that are *not* observer-dependent:
/// upper transit at Greenwich (Mer Pass GMT) for Sun and Moon.
struct AlmanacGreenwichPhenomena: Sendable {
    let sunUpperTransit: Date?
    let moonUpperTransit: Date?
    /// Sun daily averages, classical almanac footer ("vt", "vd"), arc-minutes per hour.
    let sunVt: Double
    let sunVd: Double
    /// Sun's mean apparent semi-diameter for the day, arc-minutes.
    let sunSemiDiameterMin: Double
}

/// Twilight & rise/set tabulated by latitude on the Greenwich meridian, as in
/// the classical Nautical Almanac's "phenomena at Greenwich" page.
/// Times are UT for an observer at latitude `lat` on longitude 0°.
struct LatitudeTwilightRow: Identifiable, Sendable {
    var id: Double { lat }
    let lat: Double                  // latitude in degrees, +N
    let nauticalDawn: Date?          // Sun at –12°, going up
    let civilDawn: Date?             // Sun at –6°, going up
    let sunrise: Date?               // Sun upper limb at apparent altitude 0°
    let sunset: Date?
    let civilDusk: Date?
    let nauticalDusk: Date?
}

/// One published almanac page, for a single UT date. Pure ephemeris — no
/// observer-location data is used in any computation here.
struct AlmanacDay: Sendable {
    let date: Date
    let dateString: String
    let dayOfWeek: String
    let hours: [AlmanacHourRow]
    let stars: [AlmanacStarRow]
    let phenomena: AlmanacGreenwichPhenomena
    let twilight: [LatitudeTwilightRow]
}
