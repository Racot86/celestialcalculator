import SwiftUI

struct ObserverInputView: View {
    @Bindable var store: ObserverStore
    @State private var editingAxis: CoordinateAxis?
    @State private var editingDate = false
    @State private var editingTime = false

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Observer",
                       subtitle: "POSITION • EPOCH") {
            BrutalistScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    section(title: "DATE  (UTC)") {
                        tappableRow(text: dateDisplay) { editingDate = true }
                    }
                    section(title: "TIME  (UTC, HH:MM:SS)") {
                        tappableRow(text: timeDisplay) { editingTime = true }
                    }
                    section(title: "LATITUDE") {
                        tappableRow(text: AngleFormatting.latitudeCompact(store.observer.latitude)) {
                            editingAxis = .latitude
                        }
                    }
                    section(title: "LONGITUDE") {
                        tappableRow(text: AngleFormatting.longitudeCompact(store.observer.longitude)) {
                            editingAxis = .longitude
                        }
                    }
                    section(title: "HEIGHT OF EYE  (m above sea)") {
                        HStack(spacing: 12) {
                            BrutalistSlider(value: $store.observer.elevation,
                                            range: 0...100, step: 0.5)
                            Text(String(format: "%.1f m", store.observer.elevation))
                                .font(.brutalistMonoBold(14))
                                .foregroundStyle(BrutalistTheme.foreground)
                                .frame(width: 80, alignment: .trailing)
                        }
                    }

                    Button { store.setNow() } label: {
                        Text("SNAP TO NOW")
                            .font(.brutalistTextBold(11))
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(BrutalistTheme.accent)
                            .foregroundStyle(BrutalistTheme.background)
                    }
                }
            }
        }
        .sheet(item: Binding<AxisItem?>(
            get: { editingAxis.map { AxisItem(axis: $0) } },
            set: { editingAxis = $0?.axis }
        )) { item in
            switch item.axis {
            case .latitude:
                CoordinateSheet(axis: .latitude, value: $store.observer.latitude)
            case .longitude:
                CoordinateSheet(axis: .longitude, value: $store.observer.longitude)
            }
        }
        .sheet(isPresented: $editingDate) { DateSheet(date: $store.observer.date) }
        .sheet(isPresented: $editingTime) { TimeSheet(date: $store.observer.date) }
    }

    private var dateDisplay: String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC"); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: store.observer.date)
    }

    private var timeDisplay: String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC"); f.dateFormat = "HH:mm:ss"
        return f.string(from: store.observer.date)
    }

    private func section<Content: View>(title: String,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.brutalistTextBold(9))
                .foregroundStyle(BrutalistTheme.muted)
            content()
        }
    }

    private func tappableRow(text: String,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.brutalistMonoBold(20))
                    .foregroundStyle(BrutalistTheme.foreground)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(BrutalistTheme.accent)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .overlay(Rectangle().stroke(BrutalistTheme.foreground.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var serial: String {
        let jd = JulianDate.julianDay(from: store.observer.date)
        return String(format: "JD %.5f", jd)
    }
}

private struct AxisItem: Identifiable {
    let axis: CoordinateAxis
    var id: String { axis == .latitude ? "lat" : "lon" }
}
