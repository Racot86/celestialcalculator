import SwiftUI

/// UTC time picker (HH/MM/SS) built from the custom SwiftUI `BrutalistWheel`.
struct UTCTimeWheelPicker: View {
    @Binding var date: Date

    private let utc = TimeZone(identifier: "UTC")!

    @State private var hour: Int = 0
    @State private var minute: Int = 0
    @State private var second: Int = 0

    var body: some View {
        HStack(spacing: 6) {
            column(label: "HH", items: items(0...23), binding: $hour)
            colon
            column(label: "MM", items: items(0...59), binding: $minute)
            colon
            column(label: "SS", items: items(0...59), binding: $second)
        }
        .frame(maxWidth: .infinity)
        .onAppear { syncFromDate() }
        .onChange(of: date)   { _, _ in syncFromDate() }
        .onChange(of: hour)   { _, _ in pushToDate() }
        .onChange(of: minute) { _, _ in pushToDate() }
        .onChange(of: second) { _, _ in pushToDate() }
    }

    private func items(_ range: ClosedRange<Int>) -> [BrutalistWheel<Int>.Item] {
        range.map { .init(tag: $0, title: String(format: "%02d", $0)) }
    }

    private var colon: some View {
        Text(":")
            .font(.brutalistMonoBold(20))
            .foregroundStyle(BrutalistTheme.accent)
            .frame(width: 12)
            .padding(.top, 18) // visual alignment with the wheels (label height + spacing)
    }

    private func column(label: String,
                        items: [BrutalistWheel<Int>.Item],
                        binding: Binding<Int>) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.brutalistTextBold(8))
                .foregroundStyle(BrutalistTheme.muted)
            BrutalistWheel(selection: binding, items: items, width: 60)
        }
    }

    private func syncFromDate() {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = utc
        let c = cal.dateComponents([.hour, .minute, .second], from: date)
        let h = c.hour ?? 0, m = c.minute ?? 0, s = c.second ?? 0
        if hour   != h { hour   = h }
        if minute != m { minute = m }
        if second != s { second = s }
    }

    private func pushToDate() {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = utc
        var comps = cal.dateComponents([.year, .month, .day], from: date)
        comps.timeZone = utc
        comps.hour = hour; comps.minute = minute; comps.second = second
        if let merged = cal.date(from: comps), abs(merged.timeIntervalSince(date)) > 0.1 {
            date = merged
        }
    }
}
