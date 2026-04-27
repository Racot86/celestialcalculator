import Testing
import Foundation
@testable import celestialcalculator

/// Cross-checks our generator against the published Nautical Almanac for 2026
/// (Capt. Roberto Iori, www.nauticalalmanac.it, 2025).
/// Reference values: page 1 — Thursday, January 1, 2026, 0h UT.
fileprivate let utc = TimeZone(identifier: "UTC")!

fileprivate func makeDate(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0) -> Date {
    var c = DateComponents()
    c.timeZone = utc
    c.year = y; c.month = m; c.day = d; c.hour = h
    return Calendar(identifier: .gregorian).date(from: c)!
}

fileprivate func dms(_ d: Int, _ m: Double) -> Double { Double(d) + m / 60.0 }
fileprivate func dmsN(_ d: Int, _ m: Double) -> Double { Double(d) + m / 60.0 }
fileprivate func dmsS(_ d: Int, _ m: Double) -> Double { -(Double(d) + m / 60.0) }

fileprivate func wrapDeg(_ d: Double) -> Double {
    var x = d.truncatingRemainder(dividingBy: 360.0)
    if x > 180 { x -= 360 }
    if x < -180 { x += 360 }
    return x
}

struct NauticalAlmanacReferenceTests {

    /// Jan 1 2026 — Sun & Aries GHAs at 0h, 6h, 12h, 18h UT.
    @Test func jan1_2026_sunAriesHourly() {
        let observer = Observer(date: makeDate(2026,1,1), latitude: 0, longitude: 0)
        let day = AlmanacGenerator.generate(for: observer.date)

        let cases: [(Int, Double, Double, Double)] = [
            (0,  dms(179, 10.0), dmsS(23, 1.0),  dms(100, 39.7)),
            (6,  dms(269,  8.3), dmsS(22, 59.8), dms(190, 54.5)),
            (12, dms(359,  6.5), dmsS(22, 58.6), dms(281,  9.3)),
            (18, dms( 89,  4.8), dmsS(22, 57.3), dms( 11, 24.1))
        ]
        for (h, expSunGHA, expSunDec, expAriesGHA) in cases {
            let row = day.hours[h]
            let dGHA = wrapDeg(row.sun.ghaDeg - expSunGHA)
            let dDec = row.sun.decDeg - expSunDec
            let dAr  = wrapDeg(row.ghaAriesDeg - expAriesGHA)
            let tol = 0.2 / 60.0
            #expect(abs(dGHA) < tol, "Sun GHA Δ \(dGHA*60)' at h=\(h)")
            #expect(abs(dDec) < tol, "Sun Dec Δ \(dDec*60)' at h=\(h)")
            #expect(abs(dAr)  < tol, "Aries GHA Δ \(dAr*60)' at h=\(h)")
        }
    }

    /// Jan 1 2026 — selected stars (SHA, Dec).
    @Test func jan1_2026_stars() {
        let observer = Observer(date: makeDate(2026,1,1), latitude: 0, longitude: 0)
        let day = AlmanacGenerator.generate(for: observer.date)

        let cases: [(String, Double, Double)] = [
            ("Acamar",     dms(315, 10.9), dmsS(40, 12.2)),
            ("Achernar",   dms(335, 19.4), dmsS(57,  6.5)),
            ("Acrux",      dms(172, 59.2), dmsS(63, 14.3)),
            ("Aldebaran",  dms(290, 38.4), dmsN(16, 33.7)),
            ("Altair",     dms( 61, 59.5), dmsN( 8, 56.2)),
            ("Antares",    dms(112, 15.2), dmsS(26, 29.3)),
            ("Arcturus",   dms(145, 47.3), dmsN(19,  2.7)),
            ("Capella",    dms(280, 20.2), dmsN(46,  1.5)),
            ("Deneb",      dms( 49, 25.7), dmsN(45, 22.5)),
            ("Fomalhaut",  dms( 15, 13.8), dmsS(29, 29.2)),
            ("Polaris",    dms(313, 19.8), dmsN(89, 22.7)),
            ("Rigel",      dms(281,  2.8), dmsS( 8, 10.3)),
            ("Sirius",     dms(258, 25.2), dmsS(16, 45.1)),
            ("Spica",      dms(158, 21.5), dmsS(11, 17.8)),
            ("Vega",       dms( 80, 33.1), dmsN(38, 48.4))
        ]
        let byName = Dictionary(uniqueKeysWithValues: day.stars.map { ($0.name, $0) })
        let tolGeneral = 0.2 / 60.0     // 0.2'
        // Near the pole, SHA = RA shift loses precision: 2' SHA at δ=89° is only
        // ~1.5″ on sky. Allow Polaris a wider SHA window.
        let tolPolar = 5.0 / 60.0
        for (name, expSHA, expDec) in cases {
            guard let star = byName[name] else {
                Issue.record("missing \(name)")
                continue
            }
            let dSHA = wrapDeg(star.shaDeg - expSHA)
            let dDec = star.decDeg - expDec
            let shaTol = abs(expDec) > 80 ? tolPolar : tolGeneral
            #expect(abs(dSHA) < shaTol, "\(name) SHA Δ \(dSHA*60)' (got \(star.shaDeg))")
            #expect(abs(dDec) < tolGeneral, "\(name) Dec Δ \(dDec*60)' (got \(star.decDeg))")
        }
    }

    /// Apr 27 2026 — planet GHA & Dec at 0h, 12h UT.
    /// Reference: tecepe.com.br/scripts/AlmanacPagesISAPI.dll/pages?date=04/27/2026
    @Test func apr27_2026_planetsHourly() {
        let day = AlmanacGenerator.generate(for: makeDate(2026, 4, 27))
        // (h, body, expected GHA, expected Dec) — N is positive
        let cases: [(Int, String, Double, Double)] = [
            (0,  "Aries",   dms(214, 59.8), 0),                       // Aries has no Dec
            (0,  "Venus",   dms(153, 43.7), dmsN(21, 32.9)),
            (0,  "Mars",    dms(202, 24.1), dmsN( 4, 24.6)),
            (0,  "Jupiter", dms(105,  2.4), dmsN(22, 33.7)),
            (0,  "Saturn",  dms(206,  9.7), dmsN( 1, 27.4)),
            (12, "Aries",   dms( 35, 29.4), 0),
            (12, "Venus",   dms(333, 35.1), dmsN(21, 41.2)),
            (12, "Mars",    dms( 22, 32.4), dmsN( 4, 33.7)),
            (12, "Jupiter", dms(285, 27.7), dmsN(22, 33.2)),
            (12, "Saturn",  dms( 26, 36.1), dmsN( 1, 28.7))
        ]
        let tol = 0.2 / 60.0
        for (h, body, expGHA, expDec) in cases {
            let row = day.hours[h]
            let (gha, dec): (Double, Double) = {
                switch body {
                case "Aries":   return (row.ghaAriesDeg, 0)
                case "Venus":   return (row.venus.ghaDeg,   row.venus.decDeg)
                case "Mars":    return (row.mars.ghaDeg,    row.mars.decDeg)
                case "Jupiter": return (row.jupiter.ghaDeg, row.jupiter.decDeg)
                case "Saturn":  return (row.saturn.ghaDeg,  row.saturn.decDeg)
                default: return (0, 0)
                }
            }()
            let dGHA = wrapDeg(gha - expGHA)
            #expect(abs(dGHA) < tol, "\(body) GHA Δ \(dGHA*60)' at h=\(h)")
            if body != "Aries" {
                let dDec = dec - expDec
                #expect(abs(dDec) < tol, "\(body) Dec Δ \(dDec*60)' at h=\(h)")
            }
        }
    }

    /// Sun's meridian passage at Greenwich on Jan 1 2026 — published as 12h 03m 34s.
    @Test func jan1_2026_sunMeridianPassage() {
        let observer = Observer(date: makeDate(2026,1,1), latitude: 0, longitude: 0)
        let day = AlmanacGenerator.generate(for: observer.date)
        guard let transit = day.phenomena.sunUpperTransit else {
            Issue.record("no sun transit"); return
        }
        var c = Calendar(identifier: .gregorian)
        c.timeZone = utc
        let comps = c.dateComponents([.hour, .minute, .second], from: transit)
        let hours = Double(comps.hour ?? 0) + Double(comps.minute ?? 0)/60.0 + Double(comps.second ?? 0)/3600.0
        let expected = 12.0 + 3.0/60.0 + 34.0/3600.0
        // PDF publishes to the second; ours bisects to better than 1 ms,
        // so any honest discrepancy is in the model. Allow 5 s slack.
        #expect(abs(hours - expected) * 3600.0 < 5,
                "transit Δ = \(abs(hours - expected) * 3600)s")
    }

    /// Jan 1 2026 — twilight & sunrise/sunset times by latitude on Greenwich.
    /// Reference: PDF page 1 — values published as HH:MM (1-minute precision).
    @Test func jan1_2026_twilightTable() {
        let day = AlmanacGenerator.generate(for: makeDate(2026, 1, 1))
        let byLat = Dictionary(uniqueKeysWithValues: day.twilight.map { ($0.lat, $0) })

        // (lat, nauticalDawnHHMM, sunriseHHMM, sunsetHHMM, nauticalDuskHHMM)
        let cases: [(Double, String, String, String, String)] = [
            ( 52, "06:44", "08:08", "15:59", "17:23"),
            ( 50, "06:39", "07:58", "16:09", "17:28"),
            ( 45, "06:28", "07:38", "16:29", "17:40"),
            ( 40, "06:18", "07:22", "16:45", "17:50"),
            ( 30, "06:00", "06:56", "17:11", "18:07"),
            (  0, "05:11", "06:00", "18:07", "18:56"),
            (-30, "04:02", "05:03", "19:05", "20:05")
        ]
        for (lat, nDawn, rise, set, nDusk) in cases {
            guard let row = byLat[lat] else {
                Issue.record("missing lat \(lat)")
                continue
            }
            // Two-minute slack: PDF rounds to whole minutes, our model is at
            // second precision but Sun-altitude curve is shallow at these levels.
            check(row.nauticalDawn, nDawn, label: "lat \(lat) naut dawn")
            check(row.sunrise,      rise,  label: "lat \(lat) sunrise")
            check(row.sunset,       set,   label: "lat \(lat) sunset")
            check(row.nauticalDusk, nDusk, label: "lat \(lat) naut dusk")
        }
    }

    private func check(_ date: Date?, _ expected: String, label: String) {
        guard let date else {
            Issue.record("\(label): nil")
            return
        }
        let f = DateFormatter(); f.timeZone = utc; f.dateFormat = "HH:mm"
        let actual = f.string(from: date)
        let dMin = abs(minutesSinceMidnight(actual) - minutesSinceMidnight(expected))
        #expect(dMin <= 2, "\(label): expected \(expected), got \(actual)  (Δ \(dMin) min)")
    }

    private func minutesSinceMidnight(_ hhmm: String) -> Int {
        let parts = hhmm.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }
}
