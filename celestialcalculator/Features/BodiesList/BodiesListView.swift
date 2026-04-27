import SwiftUI

struct BodiesListView: View {
    @Bindable var viewModel: BodiesListViewModel

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Nav Bodies",
                       subtitle: "TRUE BEARING (Zn) FOR ALL BODIES") {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $viewModel.hideBelowHorizon) {
                    Text("HIDE BELOW HORIZON")
                        .font(.brutalistMono(11))
                        .foregroundStyle(BrutalistTheme.foreground)
                }
                .tint(BrutalistTheme.accent)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.rows) { row in
                            BodyRowView(row: row)
                            Rectangle()
                                .fill(BrutalistTheme.foreground.opacity(0.15))
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
    }

    private var serial: String {
        let jd = JulianDate.julianDay(from: viewModel.observerStore.observer.date)
        return String(format: "JD %.4f", jd)
    }
}
