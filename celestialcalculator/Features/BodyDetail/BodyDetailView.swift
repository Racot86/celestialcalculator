import SwiftUI

struct BodyDetailView: View {
    @Bindable var viewModel: BodyDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let q = viewModel.almanac
        BrutalistPanel(serial: serial(q),
                       title: viewModel.bodyID.displayWithSymbol,
                       subtitle: "\(viewModel.bodyID.classification) • TRUE BEARING (Zn)") {
            BrutalistScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    backStrip
                    TimeStrip(date: viewModel.observerStore.observer.date)
                    hero(q)
                    Divider().background(BrutalistTheme.foreground.opacity(0.25))

                    group(title: "HORIZONTAL  (topocentric)") {
                        row("True Azimuth (Zn)",  AngleFormatting.bearing(q.horizontalTrue.azimuthDegrees))
                        row("Cardinal",           AngleFormatting.cardinal(q.horizontalTrue.azimuthDegrees))
                        row("True Altitude (Hc)", AngleFormatting.altitude(q.horizontalTrue.altitudeDegrees),
                            color: q.horizontalTrue.isAboveHorizon ? BrutalistTheme.foreground : BrutalistTheme.muted)
                        row("Apparent Altitude",  AngleFormatting.altitude(q.apparentAltitudeDegrees))
                        row("Refraction",         String(format: "%.2f'", q.refractionDegrees * 60.0))
                        if !q.horizontalTrue.isAboveHorizon {
                            Text("BELOW HORIZON")
                                .font(.brutalistTextBold(10))
                                .foregroundStyle(BrutalistTheme.signal)
                        }
                    }

                    group(title: "EQUATORIAL  (apparent of date)") {
                        let raHours = AngleMath.radToDeg(q.equatorial.rightAscension) / 15.0
                        let decDeg  = AngleMath.radToDeg(q.equatorial.declination)
                        row("Right Ascension", AngleFormatting.hms(raHours))
                        row("Declination",     AngleFormatting.degMinSec(decDeg))
                        if let dist = q.equatorial.distanceAU {
                            row("Distance (AU)", String(format: "%.6f", dist))
                        }
                    }

                    group(title: "HOUR ANGLES") {
                        row("GHA  Greenwich",  AngleFormatting.bearing(q.ghaDegrees))
                        row("LHA  Local",      AngleFormatting.bearing(q.lhaDegrees))
                        row("SHA  Sidereal",   AngleFormatting.bearing(q.shaDegrees))
                    }

                    group(title: "TIME") {
                        row("Julian Day (UT)", String(format: "%.6f", q.jdUT))
                        row("ΔT  (TT − UT, s)", String(format: "%.2f s", JulianDate.deltaT(jd: q.jdUT)))
                        row("GMST", AngleFormatting.hms(q.gmstHours))
                        row("GAST", AngleFormatting.hms(q.gastHours))
                        row("LAST", AngleFormatting.hms(q.lastHours))
                    }

                    group(title: "OBSERVER") {
                        row("Latitude",  AngleFormatting.latitudeCompact(viewModel.observerStore.observer.latitude))
                        row("Longitude", AngleFormatting.longitudeCompact(viewModel.observerStore.observer.longitude))
                        row("Height of eye", String(format: "%.1f m", viewModel.observerStore.observer.elevation))
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var backStrip: some View {
        Button { dismiss() } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .heavy))
                Text("BACK")
                    .font(.brutalistTextBold(11))
            }
            .foregroundStyle(BrutalistTheme.accent)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .overlay(Rectangle().stroke(BrutalistTheme.accent, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func hero(_ q: AlmanacQuantities) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TRUE AZIMUTH")
                    .font(.brutalistTextBold(10))
                    .foregroundStyle(BrutalistTheme.muted)
                DisplayNumeral(text: heroBearing(q.horizontalTrue.azimuthDegrees), size: 92)
                Text(AngleFormatting.bearing(q.horizontalTrue.azimuthDegrees))
                    .font(.brutalistMonoBold(15))
                    .foregroundStyle(BrutalistTheme.accent)
                Text(AngleFormatting.cardinal(q.horizontalTrue.azimuthDegrees))
                    .font(.brutalistText(11))
                    .foregroundStyle(BrutalistTheme.muted)
            }
            Spacer()
            CompassRose(trueBearingDegrees: q.horizontalTrue.azimuthDegrees)
                .frame(width: 110, height: 110)
        }
    }

    private func group<Content: View>(title: String,
                                      @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.brutalistTextBold(10))
                .foregroundStyle(BrutalistTheme.accent)
            content()
            Rectangle().fill(BrutalistTheme.foreground.opacity(0.15)).frame(height: 1)
        }
    }

    private func row(_ label: String, _ value: String, color: Color = BrutalistTheme.foreground) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.brutalistText(11))
                .foregroundStyle(BrutalistTheme.muted)
            Spacer()
            Text(value)
                .font(.brutalistMonoBold(13))
                .foregroundStyle(color)
                .textSelection(.enabled)
        }
    }

    private func heroBearing(_ d: Double) -> String {
        let n = ((d.truncatingRemainder(dividingBy: 360.0)) + 360.0).truncatingRemainder(dividingBy: 360.0)
        return String(format: "%.1f°", n)
    }

    private func serial(_ q: AlmanacQuantities) -> String {
        String(format: "JD %.4f", q.jdUT)
    }
}
