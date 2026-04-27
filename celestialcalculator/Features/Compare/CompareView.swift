import SwiftUI

struct CompareView: View {
    @Bindable var viewModel: CompareViewModel

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "USNO Compare",
                       subtitle: "VISIBLE BODIES • TEST ONLY") {
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
                    Text("Δ = APP − USNO")
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
                    .font(.brutalistLabel(13))
                    .foregroundStyle(BrutalistTheme.foreground)
                Spacer()
                if let err = row.error {
                    Text(err).font(.brutalistMono(8))
                        .foregroundStyle(BrutalistTheme.signal)
                }
            }
            // Header row
            HStack(spacing: 0) {
                col("",     align: .leading)
                col("APP",  align: .trailing)
                col("USNO", align: .trailing)
                col("Δ",    align: .trailing)
            }
            .font(.brutalistMono(8))
            .foregroundStyle(BrutalistTheme.muted)

            paramRow(name: "Zn",  app: row.appZn,  usno: row.usno?.azimuthDegrees,  delta: row.znDelta,  format: .bearing)
            paramRow(name: "Hc",  app: row.appHc,  usno: row.usno?.altitudeDegrees, delta: row.hcDelta,  format: .signed)
            paramRow(name: "GHA", app: row.appGHA, usno: row.usno?.ghaDegrees,      delta: row.ghaDelta, format: .bearing)
            paramRow(name: "Dec", app: row.appDec, usno: row.usno?.decDegrees,      delta: row.decDelta, format: .signed)
        }
        .padding(.vertical, 8)
    }

    private enum Fmt { case bearing, signed }

    @ViewBuilder
    private func paramRow(name: String,
                          app: Double,
                          usno: Double?,
                          delta: Double?,
                          format: Fmt) -> some View {
        HStack(spacing: 0) {
            Text(name).font(.brutalistMonoBold(11)).foregroundStyle(BrutalistTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(formatted(app, format: format))
                .font(.brutalistMono(11))
                .foregroundStyle(BrutalistTheme.foreground)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(usno.map { formatted($0, format: format) } ?? "—")
                .font(.brutalistMono(11))
                .foregroundStyle(BrutalistTheme.foreground)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(deltaString(delta))
                .font(.brutalistMonoBold(11))
                .foregroundStyle(deltaColor(delta))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func formatted(_ d: Double, format: Fmt) -> String {
        switch format {
        case .bearing: return AngleFormatting.bearing(d)
        case .signed:  return AngleFormatting.altitude(d)
        }
    }

    /// Delta as ± arc-minutes (1 minute = 1/60 deg).
    private func deltaString(_ d: Double?) -> String {
        guard let d else { return "—" }
        let mins = d * 60.0
        return String(format: "%+.2f'", mins)
    }

    private func deltaColor(_ d: Double?) -> Color {
        guard let d else { return BrutalistTheme.muted }
        let mins = abs(d) * 60.0
        if mins <= 1.0  { return BrutalistTheme.foreground }
        if mins <= 6.0  { return BrutalistTheme.accent }
        return BrutalistTheme.signal
    }

    private func col(_ label: String, align: HorizontalAlignment) -> some View {
        Text(label).frame(maxWidth: .infinity,
                          alignment: align == .leading ? .leading : .trailing)
    }
}
