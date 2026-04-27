import SwiftUI

/// HH/MM/SS UTC time picker — just three Pickers in `.wheel` style.
struct UTCTimeWheelPicker: View {
    @Binding var date: Date

    private let utc = TimeZone(identifier: "UTC")!

    @State private var hour: Int = 0
    @State private var minute: Int = 0
    @State private var second: Int = 0

    private let wheelHeight: CGFloat = 130

    var body: some View {
        HStack(spacing: 0) {
            wheel(label: "HH", selection: $hour,   range: 0...23)
            colon
            wheel(label: "MM", selection: $minute, range: 0...59)
            colon
            wheel(label: "SS", selection: $second, range: 0...59)
            Spacer(minLength: 0)
            Text("UTC")
                .font(.brutalistText(10))
                .foregroundStyle(BrutalistTheme.muted)
                .padding(.trailing, 6)
        }
        .frame(height: wheelHeight + 18)
        .onAppear { syncFromDate() }
        .onChange(of: date)   { _, _ in syncFromDate() }
        .onChange(of: hour)   { _, _ in pushToDate() }
        .onChange(of: minute) { _, _ in pushToDate() }
        .onChange(of: second) { _, _ in pushToDate() }
    }

    private var colon: some View {
        Text(":")
            .font(.brutalistMonoBold(20))
            .foregroundStyle(BrutalistTheme.accent)
            .frame(width: 10, height: wheelHeight + 18)
            .padding(.top, 6)
    }

    private func wheel(label: String, selection: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.brutalistTextBold(8))
                .foregroundStyle(BrutalistTheme.muted)
            Picker(label, selection: selection) {
                ForEach(Array(range), id: \.self) { v in
                    Text(String(format: "%02d", v))
                        .font(.brutalistMonoBold(17))
                        .foregroundStyle(BrutalistTheme.foreground)
                        .tag(v)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 64, height: wheelHeight)
            .clipped()
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
