import SwiftUI

/// Sheet for editing the **date** portion of the observer's UT instant.
struct DateSheet: View {
    @Binding var date: Date
    @Environment(\.dismiss) private var dismiss

    @State private var draft = Date()
    @State private var didLoad = false

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Date",
                       subtitle: "UTC  •  YEAR · MONTH · DAY") {
            VStack(alignment: .leading, spacing: 18) {
                UTCDateWheelPicker(date: $draft)
                actionButtons(today: { draft = Date() }, commit: { date = draft }, dismiss: dismiss)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onAppear { if !didLoad { draft = date; didLoad = true } }
    }

    private var serial: String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC"); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: draft)
    }
}

/// Sheet for editing the **time** portion of the observer's UT instant.
struct TimeSheet: View {
    @Binding var date: Date
    @Environment(\.dismiss) private var dismiss

    @State private var draft = Date()
    @State private var didLoad = false

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Time",
                       subtitle: "UTC  •  HH : MM : SS") {
            VStack(alignment: .leading, spacing: 18) {
                UTCTimeWheelPicker(date: $draft)
                actionButtons(today: { draft = Date() }, commit: { date = draft }, dismiss: dismiss)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onAppear { if !didLoad { draft = date; didLoad = true } }
    }

    private var serial: String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC"); f.dateFormat = "HH:mm:ss"
        return f.string(from: draft)
    }
}

@ViewBuilder
fileprivate func actionButtons(today: @escaping () -> Void,
                               commit: @escaping () -> Void,
                               dismiss: DismissAction) -> some View {
    HStack(spacing: 12) {
        Button { today() } label: {
            Text("NOW")
                .font(.brutalistTextBold(12))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .foregroundStyle(BrutalistTheme.foreground)
                .overlay(Rectangle().stroke(BrutalistTheme.foreground, lineWidth: 1))
        }
        Spacer()
        Button { dismiss() } label: {
            Text("CANCEL")
                .font(.brutalistTextBold(12))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .foregroundStyle(BrutalistTheme.foreground)
                .overlay(Rectangle().stroke(BrutalistTheme.foreground, lineWidth: 1))
        }
        Button { commit(); dismiss() } label: {
            Text("DONE")
                .font(.brutalistTextBold(12))
                .padding(.horizontal, 18).padding(.vertical, 10)
                .background(BrutalistTheme.accent)
                .foregroundStyle(BrutalistTheme.background)
        }
    }
}
