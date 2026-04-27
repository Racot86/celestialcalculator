import SwiftUI

struct CompareView: View {
    @Bindable var viewModel: CompareViewModel

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "USNO Compare",
                       subtitle: "VISIBLE BODIES ONLY • TEST ONLY") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button {
                        Task { await viewModel.fetchAll() }
                    } label: {
                        Text(viewModel.isFetching ? "FETCHING…" : "FETCH USNO")
                            .font(.brutalistMonoBold(11))
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(BrutalistTheme.accent)
                            .foregroundStyle(BrutalistTheme.background)
                    }
                    .disabled(viewModel.isFetching)
                    Spacer()
                    Text("Δ az/alt = app − USNO")
                        .font(.brutalistMono(9))
                        .foregroundStyle(BrutalistTheme.muted)
                }

                if let err = viewModel.lastError {
                    Text(err).font(.brutalistMono(10)).foregroundStyle(BrutalistTheme.signal)
                }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.rows) { row in
                            CompareRowView(row: row)
                            Rectangle().fill(BrutalistTheme.foreground.opacity(0.15)).frame(height: 1)
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.refreshLocal() }
    }

    private var serial: String {
        let jd = JulianDate.julianDay(from: viewModel.observerStore.observer.date)
        return String(format: "JD %.4f", jd)
    }
}

private struct CompareRowView: View {
    let row: CompareRow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(row.displayName.uppercased())
                    .font(.brutalistLabel(14))
                    .foregroundStyle(BrutalistTheme.foreground)
                Spacer()
                if let err = row.error {
                    Text(err.prefix(40)).font(.brutalistMono(8))
                        .foregroundStyle(BrutalistTheme.signal)
                }
            }
            HStack(alignment: .top, spacing: 12) {
                column(label: "APP",
                       az: AngleFormatting.bearing(row.appAzimuth),
                       alt: AngleFormatting.altitude(row.appAltitude),
                       color: BrutalistTheme.foreground)
                column(label: "USNO",
                       az: row.usno.map { AngleFormatting.bearing($0.azimuthDegrees) } ?? "—",
                       alt: row.usno.map { AngleFormatting.altitude($0.altitudeDegrees) } ?? "—",
                       color: BrutalistTheme.foreground)
                column(label: "Δ",
                       az: row.azimuthDelta.map { String(format: "%+.3f°", $0) } ?? "—",
                       alt: row.altitudeDelta.map { String(format: "%+.3f°", $0) } ?? "—",
                       color: deltaColor(row.azimuthDelta))
            }
        }
        .padding(.vertical, 8)
    }

    private func column(label: String, az: String, alt: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label).font(.brutalistMono(8)).foregroundStyle(BrutalistTheme.muted)
            Text(az).font(.brutalistMonoBold(12)).foregroundStyle(color)
            Text(alt).font(.brutalistMono(11)).foregroundStyle(color.opacity(0.8))
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func deltaColor(_ d: Double?) -> Color {
        guard let d else { return BrutalistTheme.muted }
        let mag = abs(d)
        if mag < 0.05 { return BrutalistTheme.foreground }      // ≤ 3'
        if mag < 0.5  { return BrutalistTheme.accent }           // ≤ 30'
        return BrutalistTheme.signal
    }
}
