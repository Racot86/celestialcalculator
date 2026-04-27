import SwiftUI

struct BodiesListView: View {
    @Bindable var viewModel: BodiesListViewModel

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Nav Bodies",
                       subtitle: "TRUE BEARING (Zn) FOR ALL BODIES") {
            VStack(alignment: .leading, spacing: 8) {
                TimeStrip(date: viewModel.observerStore.observer.date)
                BrutalistToggle(isOn: $viewModel.hideBelowHorizon,
                                label: "Hide below horizon")

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.rows) { row in
                            NavigationLink(value: row.bodyID) {
                                BodyRowView(row: row)
                            }
                            .buttonStyle(.plain)
                            Rectangle()
                                .fill(BrutalistTheme.foreground.opacity(0.15))
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var serial: String {
        let jd = JulianDate.julianDay(from: viewModel.observerStore.observer.date)
        return String(format: "JD %.4f", jd)
    }
}
