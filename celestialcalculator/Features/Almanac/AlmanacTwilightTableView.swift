import SwiftUI

/// Classical "phenomena at Greenwich" table: rise/set + civil & nautical
/// twilight times, tabulated by latitude on the Greenwich meridian.
struct AlmanacTwilightTableView: View {
    let rows: [LatitudeTwilightRow]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                Rectangle().fill(BrutalistTheme.foreground.opacity(0.4)).frame(height: 1)
                ForEach(rows) { row in
                    dataRow(row)
                    Rectangle().fill(BrutalistTheme.foreground.opacity(0.08)).frame(height: 1)
                }
            }
        }
    }

    private let wLat: CGFloat = 56
    private let wTime: CGFloat = 64

    private var header: some View {
        HStack(spacing: 6) {
            Text("LAT").frame(width: wLat, alignment: .trailing)
            Text("NAUT").frame(width: wTime, alignment: .center)
            Text("CIVIL").frame(width: wTime, alignment: .center)
            Text("RISE").frame(width: wTime, alignment: .center)
            Text("SET").frame(width: wTime, alignment: .center)
            Text("CIVIL").frame(width: wTime, alignment: .center)
            Text("NAUT").frame(width: wTime, alignment: .center)
        }
        .font(.brutalistMono(8))
        .foregroundStyle(BrutalistTheme.muted)
        .padding(.vertical, 4)
    }

    private func dataRow(_ row: LatitudeTwilightRow) -> some View {
        HStack(spacing: 6) {
            Text(latLabel(row.lat))
                .font(.brutalistMonoBold(11))
                .foregroundStyle(BrutalistTheme.accent)
                .frame(width: wLat, alignment: .trailing)
            time(row.nauticalDawn)
            time(row.civilDawn)
            time(row.sunrise)
            time(row.sunset)
            time(row.civilDusk)
            time(row.nauticalDusk)
        }
        .font(.brutalistMono(11))
        .foregroundStyle(BrutalistTheme.foreground)
        .padding(.vertical, 3)
    }

    private func time(_ d: Date?) -> some View {
        Text(hhmm(d))
            .font(.brutalistMono(11))
            .frame(width: wTime, alignment: .center)
    }

    private func hhmm(_ date: Date?) -> String {
        guard let date else { return "—" }
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func latLabel(_ lat: Double) -> String {
        if lat == 0 { return "0°" }
        let suffix = lat > 0 ? "N" : "S"
        return String(format: "%d°%@", Int(abs(lat)), suffix)
    }
}
