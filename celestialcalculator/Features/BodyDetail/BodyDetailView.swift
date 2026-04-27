import SwiftUI

struct BodyDetailView: View {
    @Bindable var viewModel: BodyDetailViewModel
    @State private var showDiagnostics = false

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: viewModel.bodyID.displayWithSymbol,
                       subtitle: "\(viewModel.bodyID.classification) • TRUE BEARING (Zn)") {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    BodyPickerView(selection: $viewModel.bodyID)
                    Spacer()
                    Button { showDiagnostics = true } label: {
                        Text("USNO COMPARE")
                            .font(.brutalistMonoBold(10))
                            .padding(.horizontal, 8).padding(.vertical, 6)
                            .background(BrutalistTheme.accent)
                            .foregroundStyle(BrutalistTheme.background)
                    }
                }

                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TRUE AZIMUTH")
                            .font(.brutalistMono(10))
                            .foregroundStyle(BrutalistTheme.muted)
                        DisplayNumeral(text: heroBearing(horizontal.azimuthDegrees), size: 92)
                        Text(AngleFormatting.bearing(horizontal.azimuthDegrees))
                            .font(.brutalistMonoBold(15))
                            .foregroundStyle(BrutalistTheme.accent)
                        Text(AngleFormatting.cardinal(horizontal.azimuthDegrees))
                            .font(.brutalistMono(11))
                            .foregroundStyle(BrutalistTheme.muted)
                    }
                    Spacer()
                    CompassRose(trueBearingDegrees: horizontal.azimuthDegrees)
                        .frame(width: 110, height: 110)
                }

                Divider().background(BrutalistTheme.foreground.opacity(0.25))

                HStack(spacing: 18) {
                    LabeledValue(label: "ALTITUDE",
                                 value: AngleFormatting.altitude(horizontal.altitudeDegrees),
                                 valueColor: horizontal.isAboveHorizon
                                    ? BrutalistTheme.foreground
                                    : BrutalistTheme.muted)
                    LabeledValue(label: "DECLINATION",
                                 value: AngleFormatting.altitude(AngleMath.radToDeg(equatorial.declination)))
                    LabeledValue(label: "RA (h)",
                                 value: String(format: "%.4f", AngleMath.radToDeg(equatorial.rightAscension) / 15.0))
                }

                if !horizontal.isAboveHorizon {
                    Text("BELOW HORIZON")
                        .font(.brutalistMonoBold(10))
                        .foregroundStyle(BrutalistTheme.signal)
                        .padding(.top, 4)
                }
            }
        }
        .sheet(isPresented: $showDiagnostics) {
            BodyDiagnosticsView(bodyID: viewModel.bodyID,
                                observer: viewModel.observerStore.observer)
        }
    }

    private var horizontal: HorizontalCoordinates { viewModel.horizontal }
    private var equatorial: EquatorialCoordinates { viewModel.equatorial }

    /// Hero numeral, e.g. "248.0°".
    private func heroBearing(_ d: Double) -> String {
        let n = ((d.truncatingRemainder(dividingBy: 360.0)) + 360.0).truncatingRemainder(dividingBy: 360.0)
        return String(format: "%.1f°", n)
    }

    private var serial: String {
        let jd = JulianDate.julianDay(from: viewModel.observerStore.observer.date)
        return String(format: "JD %.4f", jd)
    }
}
