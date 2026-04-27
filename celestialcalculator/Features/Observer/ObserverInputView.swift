import SwiftUI

struct ObserverInputView: View {
    @Bindable var store: ObserverStore

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Observer",
                       subtitle: "POSITION • EPOCH") {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    section(title: "DATE / TIME (UTC)") {
                        DatePicker("",
                                   selection: $store.observer.date,
                                   displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .environment(\.timeZone, TimeZone(identifier: "UTC")!)
                            .tint(BrutalistTheme.accent)
                    }

                    section(title: "LATITUDE   DD-MM.M' N/S") {
                        CoordinateWheelPicker(axis: .latitude,
                                              value: $store.observer.latitude)
                    }

                    section(title: "LONGITUDE  DDD-MM.M' E/W") {
                        CoordinateWheelPicker(axis: .longitude,
                                              value: $store.observer.longitude)
                    }

                    section(title: "ELEVATION (m)") {
                        HStack {
                            Slider(value: $store.observer.elevation, in: 0...4000, step: 1)
                                .tint(BrutalistTheme.accent)
                            Text("\(Int(store.observer.elevation)) m")
                                .font(.brutalistMonoBold(13))
                                .foregroundStyle(BrutalistTheme.foreground)
                                .frame(width: 70, alignment: .trailing)
                        }
                    }

                    HStack {
                        Button {
                            store.setNow()
                        } label: {
                            Text("SYNC NOW")
                                .font(.brutalistMonoBold(11))
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(BrutalistTheme.accent)
                                .foregroundStyle(BrutalistTheme.background)
                        }
                        Spacer()
                        KanjiTag()
                    }
                }
            }
        }
    }

    private func section<Content: View>(title: String,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.brutalistMono(9))
                .foregroundStyle(BrutalistTheme.muted)
            content()
        }
    }

    private var serial: String {
        let jd = JulianDate.julianDay(from: store.observer.date)
        return String(format: "JD %.5f", jd)
    }
}
