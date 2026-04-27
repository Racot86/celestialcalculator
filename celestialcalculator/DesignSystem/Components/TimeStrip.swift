import SwiftUI

/// Live UTC date + HH:MM:SS strip. Ticks every second. The strip shows the
/// observer's `date` — when the observer is tracking real time it advances live;
/// when the user has frozen a specific instant, the strip stays at that instant.
struct TimeStrip: View {
    let date: Date

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(dateString)
                .font(.brutalistMonoBold(13))
                .foregroundStyle(BrutalistTheme.foreground)
            Text(timeString)
                .font(.brutalistMonoBold(15))
                .foregroundStyle(BrutalistTheme.accent)
            Text("UTC")
                .font(.brutalistMono(9))
                .foregroundStyle(BrutalistTheme.muted)
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private var timeString: String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }
}
