import Foundation

/// Finds rise / set / transit / twilight events by scanning altitude across the
/// UT day in 10-minute steps, then bisecting on sign-change intervals.
enum AlmanacEventFinder {
    static let stepSeconds: TimeInterval = 600

    /// Reference altitude for which we declare "rise/set" — corrects for refraction
    /// at the horizon and the body's angular semi-diameter.
    enum Threshold {
        case sunCenter        //   0° geometric (true alt)
        case sunUpperLimb     //  -50′ apparent (refraction 34′ + SD 16′)
        case civil            //  -6°
        case nautical         // -12°
        case astronomical     // -18°
        case moonUpperLimb    //  -34′ refraction + 15.5′ mean SD = -49.5′; varies w/ HP

        var altitudeDegrees: Double {
            switch self {
            case .sunCenter:     return 0
            case .sunUpperLimb:  return -50.0 / 60.0
            case .civil:         return -6
            case .nautical:      return -12
            case .astronomical:  return -18
            case .moonUpperLimb: return -34.0 / 60.0   // refraction; SD added separately for Moon below
            }
        }
    }

    /// Find the FIRST time on the UT day when the body's altitude crosses the threshold
    /// in the requested direction. `rising = true` looks for –→+ (rise), false for +→– (set).
    static func crossing(bodyID: CelestialBodyID,
                         observer: Observer,
                         dayStartUT: Date,
                         threshold: Threshold,
                         rising: Bool) -> Date? {
        let body = BodyFactory.body(for: bodyID)
        let target = threshold.altitudeDegrees
        var prevTime = dayStartUT
        var prevAlt = altitude(body: body, at: prevTime, observer: observer, threshold: threshold)
        var t: TimeInterval = stepSeconds
        while t <= 86400 + 0.5 {
            let curTime = dayStartUT.addingTimeInterval(t)
            let curAlt = altitude(body: body, at: curTime, observer: observer, threshold: threshold)
            let crossesUp = prevAlt - target < 0 && curAlt - target >= 0
            let crossesDn = prevAlt - target > 0 && curAlt - target <= 0
            if (rising && crossesUp) || (!rising && crossesDn) {
                return bisect(body: body, observer: observer,
                              t0: prevTime, t1: curTime,
                              threshold: threshold, target: target)
            }
            prevTime = curTime
            prevAlt = curAlt
            t += stepSeconds
        }
        return nil
    }

    /// Upper-transit time = when the body crosses the local meridian going from east to west.
    /// Detected as the moment azimuth crosses 180° (on the south/north line, allowing for pole)
    /// — equivalently, hour angle goes from –→+. We use HA crossing.
    static func upperTransit(bodyID: CelestialBodyID,
                             observer: Observer,
                             dayStartUT: Date) -> Date? {
        let body = BodyFactory.body(for: bodyID)
        var prevTime = dayStartUT
        var prevHA = hourAngle(body: body, at: prevTime, observer: observer)
        var t: TimeInterval = stepSeconds
        while t <= 86400 + 0.5 {
            let curTime = dayStartUT.addingTimeInterval(t)
            let curHA = hourAngle(body: body, at: curTime, observer: observer)
            // HA goes 0 → 2π; transit is where HA wraps past 0 (i.e. HA was near 2π and now near 0).
            let cross = (prevHA > .pi && curHA < .pi) || (prevHA < .pi && curHA < prevHA && (prevHA - curHA) < .pi)
            if cross {
                return bisectHA(body: body, observer: observer, t0: prevTime, t1: curTime)
            }
            prevTime = curTime
            prevHA = curHA
            t += stepSeconds
        }
        return nil
    }

    // MARK: - private

    private static func altitude(body: CelestialBody, at date: Date, observer: Observer,
                                 threshold: Threshold) -> Double {
        var obs = observer
        obs.date = date
        let h = body.horizontalCoordinates(for: obs)
        var alt = h.altitudeDegrees
        // Adjust threshold-specific corrections that we baked into Threshold:
        // for Moon upper limb, also subtract approximate SD (~15.5')
        if case .moonUpperLimb = threshold {
            alt -= 15.5 / 60.0
        }
        return alt
    }

    private static func hourAngle(body: CelestialBody, at date: Date, observer: Observer) -> Double {
        let jd = JulianDate.julianDay(from: date)
        let eq = body.apparentEquatorial(jdUT: jd)
        let lon = AngleMath.degToRad(observer.longitude)
        let lst = SiderealTime.last(jdUT: jd, longitudeEastRad: lon)
        var ha = lst - eq.rightAscension
        if ha < 0 { ha += 2 * .pi }
        if ha >= 2 * .pi { ha -= 2 * .pi }
        return ha
    }

    private static func bisect(body: CelestialBody, observer: Observer,
                               t0: Date, t1: Date, threshold: Threshold, target: Double) -> Date {
        var lo = t0, hi = t1
        for _ in 0..<24 {
            let mid = lo.addingTimeInterval((hi.timeIntervalSince(lo)) / 2)
            let altMid = altitude(body: body, at: mid, observer: observer, threshold: threshold)
            let altLo  = altitude(body: body, at: lo, observer: observer, threshold: threshold)
            if (altLo - target) * (altMid - target) <= 0 { hi = mid } else { lo = mid }
        }
        return lo.addingTimeInterval(hi.timeIntervalSince(lo) / 2)
    }

    private static func bisectHA(body: CelestialBody, observer: Observer, t0: Date, t1: Date) -> Date {
        var lo = t0, hi = t1
        for _ in 0..<24 {
            let mid = lo.addingTimeInterval((hi.timeIntervalSince(lo)) / 2)
            let haMid = hourAngle(body: body, at: mid, observer: observer)
            let haLo  = hourAngle(body: body, at: lo, observer: observer)
            // Pick half where HA is "smaller" relative to wrap point at 0/2π near transit.
            let normLo = haLo > .pi ? haLo - 2 * .pi : haLo
            let normMid = haMid > .pi ? haMid - 2 * .pi : haMid
            if normLo * normMid <= 0 { hi = mid } else { lo = mid }
        }
        return lo.addingTimeInterval(hi.timeIntervalSince(lo) / 2)
    }
}
