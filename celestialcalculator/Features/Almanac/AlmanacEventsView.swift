import SwiftUI

/// Greenwich-only phenomena: Sun & Moon Mer Pass and Sun daily averages.
struct AlmanacEventsView: View {
    let phenomena: AlmanacGreenwichPhenomena

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MERIDIAN PASSAGE AT GREENWICH  (UT)")
                .font(.brutalistMonoBold(10))
                .foregroundStyle(BrutalistTheme.accent)
            row(label: "Sun",  text: hhmmss(phenomena.sunUpperTransit))
            row(label: "Moon", text: hhmmss(phenomena.moonUpperTransit))
            Spacer().frame(height: 6)
            Text("SUN — DAILY AVERAGES")
                .font(.brutalistMonoBold(10))
                .foregroundStyle(BrutalistTheme.accent)
            row(label: "v",  text: String(format: "%+.1f'", phenomena.sunVt))
            row(label: "d",  text: String(format: "%+.1f'", phenomena.sunVd))
            row(label: "SD", text: String(format: "%.2f'", phenomena.sunSemiDiameterMin))
            Rectangle().fill(BrutalistTheme.foreground.opacity(0.15)).frame(height: 1)
        }
    }

    private func row(label: String, text: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.brutalistMono(10))
                .foregroundStyle(BrutalistTheme.muted)
            Spacer()
            Text(text)
                .font(.brutalistMonoBold(13))
                .foregroundStyle(BrutalistTheme.foreground)
        }
    }

    private func hhmmss(_ date: Date?) -> String {
        guard let date else { return "—" }
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }
}
