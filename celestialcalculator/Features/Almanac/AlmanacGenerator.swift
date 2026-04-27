import Foundation

/// Builds a published-style almanac page for a UT date.
/// All output is **observer-independent** — the only inputs are the date and the
/// fixed standard-latitude rows used by the classical Nautical Almanac.
enum AlmanacGenerator {
    private static let utc = TimeZone(identifier: "UTC")!

    /// Standard latitude rows used by the printed almanac for the rise/set/twilight
    /// table (positive = North).
    private static let standardLatitudes: [Double] = [
        72, 70, 68, 66, 64, 62, 60, 58, 56, 54, 52, 50, 45, 40, 35, 30, 20, 10,
        0,
        -10, -20, -30, -35, -40, -45, -50, -52, -54, -56, -58, -60
    ]

    static func generate(for date: Date) -> AlmanacDay {
        let dayStart = startOfUTDay(date)

        var samples: [HourlySample] = []
        for h in 0...24 {
            let t = dayStart.addingTimeInterval(Double(h) * 3600.0)
            samples.append(HourlySample(time: t))
        }

        var rows: [AlmanacHourRow] = []
        for h in 0..<24 {
            let s0 = samples[h]
            let s1 = samples[h + 1]
            rows.append(AlmanacHourRow(
                hour: h,
                ghaAriesDeg: s0.ghaAries,
                sun:     bodyHourly(s0.sun,     s1.sun,     standardIncDeg: 15.0,            body: .sun),
                venus:   bodyHourly(s0.venus,   s1.venus,   standardIncDeg: 15.0,            body: .planet(.venus)),
                mars:    bodyHourly(s0.mars,    s1.mars,    standardIncDeg: 15.0,            body: .planet(.mars)),
                jupiter: bodyHourly(s0.jupiter, s1.jupiter, standardIncDeg: 15.0,            body: .planet(.jupiter)),
                saturn:  bodyHourly(s0.saturn,  s1.saturn,  standardIncDeg: 15.0,            body: .planet(.saturn)),
                moon:    bodyHourly(s0.moon,    s1.moon,    standardIncDeg: 14.0 + 19.0/60.0,
                                    body: .moon)
            ))
        }

        let stars = buildStars(at: dayStart.addingTimeInterval(12 * 3600))
        let phenomena = buildPhenomena(dayStart: dayStart, hours: rows)
        let twilight = buildTwilightTable(dayStart: dayStart)

        let df = DateFormatter(); df.timeZone = utc; df.dateFormat = "yyyy-MM-dd"
        let dn = DateFormatter(); dn.timeZone = utc; dn.dateFormat = "EEEE"

        return AlmanacDay(
            date: dayStart,
            dateString: df.string(from: dayStart),
            dayOfWeek: dn.string(from: dayStart).uppercased(),
            hours: rows,
            stars: stars,
            phenomena: phenomena,
            twilight: twilight
        )
    }

    // MARK: - Hourly sampling

    private struct BodySample {
        let gha: Double
        let dec: Double
        let distanceAU: Double?
    }

    private struct HourlySample {
        let time: Date
        let ghaAries: Double
        let sun, venus, mars, jupiter, saturn, moon: BodySample

        init(time: Date) {
            self.time = time
            let jd = JulianDate.julianDay(from: time)
            let gastDeg = AngleMath.radToDeg(SiderealTime.gast(jdUT: jd))
            self.ghaAries = AngleMath.normalizeDegrees(gastDeg)
            self.sun     = HourlySample.sample(.sun, jd: jd, gastDeg: gastDeg)
            self.venus   = HourlySample.sample(.planet(.venus), jd: jd, gastDeg: gastDeg)
            self.mars    = HourlySample.sample(.planet(.mars), jd: jd, gastDeg: gastDeg)
            self.jupiter = HourlySample.sample(.planet(.jupiter), jd: jd, gastDeg: gastDeg)
            self.saturn  = HourlySample.sample(.planet(.saturn), jd: jd, gastDeg: gastDeg)
            self.moon    = HourlySample.sample(.moon, jd: jd, gastDeg: gastDeg)
        }

        private static func sample(_ id: CelestialBodyID, jd: Double, gastDeg: Double) -> BodySample {
            let eq = BodyFactory.body(for: id).apparentEquatorial(jdUT: jd)
            let raDeg = AngleMath.radToDeg(eq.rightAscension)
            let gha = AngleMath.normalizeDegrees(gastDeg - raDeg)
            let dec = AngleMath.radToDeg(eq.declination)
            return BodySample(gha: gha, dec: dec, distanceAU: eq.distanceAU)
        }
    }

    private static func bodyHourly(_ s0: BodySample, _ s1: BodySample,
                                   standardIncDeg: Double, body: CelestialBodyID) -> BodyHourly {
        var inc = s1.gha - s0.gha
        if inc < -180 { inc += 360 }
        if inc > 180  { inc -= 360 }
        let vMin = (inc - standardIncDeg) * 60.0
        let dMin = (s1.dec - s0.dec) * 60.0

        var sd: Double? = nil
        var hp: Double? = nil
        switch body {
        case .sun:
            if let d = s0.distanceAU, d > 0 { sd = 16.0 / d } else { sd = 16.0 }
        case .moon:
            hp = 57.0
            sd = 15.5
        default: break
        }

        return BodyHourly(ghaDeg: s0.gha, decDeg: s0.dec,
                          vMinPerHour: vMin, dMinPerHour: dMin,
                          sdMin: sd, hpMin: hp)
    }

    // MARK: - Stars

    private static func buildStars(at date: Date) -> [AlmanacStarRow] {
        let jd = JulianDate.julianDay(from: date)
        return (0..<NavigationalStars.count).map { i in
            let entry = NavigationalStars.all[i]
            let star = Star(catalogIndex: i)
            let eq = star.apparentEquatorial(jdUT: jd)
            let raDeg = AngleMath.radToDeg(eq.rightAscension)
            let sha = AngleMath.normalizeDegrees(360.0 - raDeg)
            let dec = AngleMath.radToDeg(eq.declination)
            return AlmanacStarRow(name: entry.name, bayer: entry.bayer,
                                  magnitude: entry.magnitude, shaDeg: sha, decDeg: dec)
        }
    }

    // MARK: - Greenwich phenomena

    private static func buildPhenomena(dayStart: Date, hours: [AlmanacHourRow]) -> AlmanacGreenwichPhenomena {
        // vt = mean over the day of v (Sun is special — published as a single value)
        let vt = hours.reduce(0.0) { $0 + ($1.sun.vMinPerHour ?? 0) } / Double(hours.count)
        let vd = hours.reduce(0.0) { $0 + $1.sun.dMinPerHour } / Double(hours.count)
        let sd = hours.reduce(0.0) { $0 + ($1.sun.sdMin ?? 0) } / Double(hours.count)
        let sun  = greenwichTransit(bodyID: .sun, dayStart: dayStart)
        let moon = greenwichTransit(bodyID: .moon, dayStart: dayStart)
        return AlmanacGreenwichPhenomena(
            sunUpperTransit: sun, moonUpperTransit: moon,
            sunVt: vt, sunVd: vd, sunSemiDiameterMin: sd
        )
    }

    /// Sun/Moon upper transit at Greenwich = the UT instant when GHA_body crosses
    /// from <360° into the next [0,360) cycle (i.e. through 0°).
    /// 60-second scan, then bisection — yields second-level precision.
    private static func greenwichTransit(bodyID: CelestialBodyID, dayStart: Date) -> Date? {
        let body = BodyFactory.body(for: bodyID)
        let step: TimeInterval = 60
        var prev = dayStart
        var prevGHA = ghaDeg(body: body, at: prev)
        var t: TimeInterval = step
        while t <= 86400 + 0.5 {
            let cur = dayStart.addingTimeInterval(t)
            let curGHA = ghaDeg(body: body, at: cur)
            if prevGHA > 180 && curGHA < 180 && (prevGHA - curGHA) > 180 {
                return bisectGHA(body: body, t0: prev, t1: cur)
            }
            prev = cur; prevGHA = curGHA; t += step
        }
        return nil
    }

    private static func ghaDeg(body: CelestialBody, at date: Date) -> Double {
        let jd = JulianDate.julianDay(from: date)
        let eq = body.apparentEquatorial(jdUT: jd)
        let gast = AngleMath.radToDeg(SiderealTime.gast(jdUT: jd))
        return AngleMath.normalizeDegrees(gast - AngleMath.radToDeg(eq.rightAscension))
    }

    private static func bisectGHA(body: CelestialBody, t0: Date, t1: Date) -> Date {
        var lo = t0, hi = t1
        for _ in 0..<32 {
            let mid = lo.addingTimeInterval(hi.timeIntervalSince(lo) / 2)
            let g = ghaDeg(body: body, at: mid)
            let gN = g > 180 ? g - 360 : g
            if gN < 0 { lo = mid } else { hi = mid }
        }
        return lo.addingTimeInterval(hi.timeIntervalSince(lo) / 2)
    }

    // MARK: - Twilight table by latitude

    private static func buildTwilightTable(dayStart: Date) -> [LatitudeTwilightRow] {
        return standardLatitudes.map { lat in
            LatitudeTwilightRow(
                lat: lat,
                nauticalDawn: sunAltitudeCrossing(dayStart: dayStart, lat: lat,
                                                  altDeg: -12, rising: true),
                civilDawn:    sunAltitudeCrossing(dayStart: dayStart, lat: lat,
                                                  altDeg: -6, rising: true),
                sunrise:      sunAltitudeCrossing(dayStart: dayStart, lat: lat,
                                                  altDeg: -50.0/60.0, rising: true),
                sunset:       sunAltitudeCrossing(dayStart: dayStart, lat: lat,
                                                  altDeg: -50.0/60.0, rising: false),
                civilDusk:    sunAltitudeCrossing(dayStart: dayStart, lat: lat,
                                                  altDeg: -6, rising: false),
                nauticalDusk: sunAltitudeCrossing(dayStart: dayStart, lat: lat,
                                                  altDeg: -12, rising: false)
            )
        }
    }

    /// Find the UT instant on the day when the Sun's altitude crosses `altDeg`
    /// at latitude `lat` on the Greenwich meridian. `rising` selects the morning
    /// (upward) or evening (downward) crossing.
    private static func sunAltitudeCrossing(dayStart: Date, lat: Double,
                                            altDeg target: Double, rising: Bool) -> Date? {
        let sun = Sun()
        let phi = AngleMath.degToRad(lat)
        let step: TimeInterval = 600
        var prevTime = dayStart
        var prevAlt = sunAltitudeDeg(sun: sun, at: prevTime, latRad: phi)
        var t: TimeInterval = step
        while t <= 86400 + 0.5 {
            let curTime = dayStart.addingTimeInterval(t)
            let curAlt = sunAltitudeDeg(sun: sun, at: curTime, latRad: phi)
            let crossesUp = prevAlt - target < 0 && curAlt - target >= 0
            let crossesDn = prevAlt - target > 0 && curAlt - target <= 0
            if (rising && crossesUp) || (!rising && crossesDn) {
                return bisectSunAlt(sun: sun, latRad: phi, target: target,
                                    t0: prevTime, t1: curTime)
            }
            prevTime = curTime; prevAlt = curAlt; t += step
        }
        return nil
    }

    private static func sunAltitudeDeg(sun: Sun, at date: Date, latRad phi: Double) -> Double {
        let jd = JulianDate.julianDay(from: date)
        let eq = sun.apparentEquatorial(jdUT: jd)
        let lst = SiderealTime.last(jdUT: jd, longitudeEastRad: 0)
        let ha = lst - eq.rightAscension
        let sinAlt = sin(phi) * sin(eq.declination)
                   + cos(phi) * cos(eq.declination) * cos(ha)
        return AngleMath.radToDeg(asin(max(-1, min(1, sinAlt))))
    }

    private static func bisectSunAlt(sun: Sun, latRad phi: Double, target: Double,
                                     t0: Date, t1: Date) -> Date {
        var lo = t0, hi = t1
        let altLo = sunAltitudeDeg(sun: sun, at: lo, latRad: phi) - target
        for _ in 0..<32 {
            let mid = lo.addingTimeInterval(hi.timeIntervalSince(lo) / 2)
            let altMid = sunAltitudeDeg(sun: sun, at: mid, latRad: phi) - target
            if altLo * altMid <= 0 { hi = mid } else { lo = mid }
        }
        return lo.addingTimeInterval(hi.timeIntervalSince(lo) / 2)
    }

    private static func startOfUTDay(_ date: Date) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        return cal.date(from: comps) ?? date
    }
}
