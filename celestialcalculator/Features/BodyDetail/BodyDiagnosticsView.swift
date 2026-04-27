import SwiftUI

/// Full almanac-style data dump for a single body. Mirrors the columns shown by
/// USNO's celestial-navigation table so the user can spot-check our values
/// against https://aa.usno.navy.mil/data/celnavtable .
struct BodyDiagnosticsView: View {
    let bodyID: CelestialBodyID
    let observer: Observer

    var body: some View {
        let q = AlmanacCalculator.compute(bodyID: bodyID, observer: observer)
        return BrutalistPanel(serial: String(format: "JD %.5f", q.jdUT),
                              title: "Almanac Data",
                              subtitle: "USNO COMPARE • \(bodyID.displayName.uppercased())") {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    group(title: "TIME") {
                        row("Julian Day (UT)", String(format: "%.6f", q.jdUT))
                        row("ΔT  (TT − UT, s)", String(format: "%.2f s", JulianDate.deltaT(jd: q.jdUT)))
                        row("GMST", AngleFormatting.hms(q.gmstHours))
                        row("GAST", AngleFormatting.hms(q.gastHours))
                        row("LAST", AngleFormatting.hms(q.lastHours))
                    }

                    group(title: "EQUATORIAL (apparent, of date)") {
                        let raHours = AngleMath.radToDeg(q.equatorial.rightAscension) / 15.0
                        let decDeg = AngleMath.radToDeg(q.equatorial.declination)
                        row("Right Ascension", AngleFormatting.hms(raHours))
                        row("Declination", AngleFormatting.degMinSec(decDeg))
                        if let dist = q.equatorial.distanceAU {
                            row("Distance (AU)", String(format: "%.6f", dist))
                        }
                    }

                    group(title: "HOUR ANGLES") {
                        row("GHA  (Greenwich)", AngleFormatting.bearing(q.ghaDegrees))
                        row("LHA  (Local)",     AngleFormatting.bearing(q.lhaDegrees))
                        row("SHA  (Sidereal)",  AngleFormatting.bearing(q.shaDegrees))
                    }

                    group(title: "HORIZONTAL (topocentric)") {
                        row("True Azimuth (Zn)",  AngleFormatting.bearing(q.horizontalTrue.azimuthDegrees))
                        row("True Altitude (Hc)", AngleFormatting.altitude(q.horizontalTrue.altitudeDegrees))
                        row("Apparent Altitude",  AngleFormatting.altitude(q.apparentAltitudeDegrees))
                        row("Refraction",         String(format: "%.2f'", q.refractionDegrees * 60.0))
                        row("Cardinal",           AngleFormatting.cardinal(q.horizontalTrue.azimuthDegrees))
                    }

                    group(title: "OBSERVER") {
                        row("Latitude",  AngleFormatting.altitude(observer.latitude))
                        row("Longitude", AngleFormatting.altitude(observer.longitude))
                        row("Elevation", String(format: "%.0f m", observer.elevation))
                    }

                    Text("Compare against aa.usno.navy.mil/data/celnavtable using identical UT and position. Field names match USNO conventions.")
                        .font(.brutalistMono(9))
                        .foregroundStyle(BrutalistTheme.muted)
                        .padding(.top, 4)
                }
            }
        }
    }

    private func group<Content: View>(title: String,
                                      @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.brutalistMonoBold(10))
                .foregroundStyle(BrutalistTheme.accent)
            content()
            Rectangle().fill(BrutalistTheme.foreground.opacity(0.15)).frame(height: 1)
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.brutalistMono(11))
                .foregroundStyle(BrutalistTheme.muted)
            Spacer()
            Text(value)
                .font(.brutalistMonoBold(13))
                .foregroundStyle(BrutalistTheme.foreground)
                .textSelection(.enabled)
        }
    }
}
