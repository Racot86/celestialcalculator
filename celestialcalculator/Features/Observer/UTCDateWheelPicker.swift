import SwiftUI

/// Pure-wheel UTC date picker: Year / Month / Day. No system DatePicker, no
/// glass, no system blur — just three Pickers in `.wheel` style with our fonts.
struct UTCDateWheelPicker: View {
    @Binding var date: Date

    private let utc = TimeZone(identifier: "UTC")!

    @State private var year: Int = 2026
    @State private var month: Int = 1
    @State private var day: Int = 1

    private let yearRange = 1900...2100
    private let wheelHeight: CGFloat = 130

    var body: some View {
        HStack(spacing: 0) {
            wheel(label: "YEAR",  selection: $year,  range: yearRange,  format: "%04d", width: 90)
            wheel(label: "MONTH", selection: $month, range: 1...12,     format: "%02d", width: 64)
            wheel(label: "DAY",   selection: $day,   range: 1...daysInMonth(),
                                                                       format: "%02d", width: 64)
            Spacer(minLength: 0)
        }
        .frame(height: wheelHeight + 18)
        .onAppear { syncFromDate() }
        .onChange(of: date)  { _, _ in syncFromDate() }
        .onChange(of: year)  { _, _ in clampDay(); pushToDate() }
        .onChange(of: month) { _, _ in clampDay(); pushToDate() }
        .onChange(of: day)   { _, _ in pushToDate() }
    }

    private func wheel<R: RandomAccessCollection>(label: String,
                                                  selection: Binding<Int>,
                                                  range: R,
                                                  format: String,
                                                  width: CGFloat) -> some View where R.Element == Int {
        VStack(spacing: 2) {
            Text(label).font(.brutalistTextBold(8))
                .foregroundStyle(BrutalistTheme.muted)
            Picker(label, selection: selection) {
                ForEach(Array(range), id: \.self) { v in
                    Text(String(format: format, v))
                        .font(.brutalistMonoBold(17))
                        .foregroundStyle(BrutalistTheme.foreground)
                        .tag(v)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: width, height: wheelHeight)
            .clipped()
        }
    }

    private func daysInMonth() -> Int {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = utc
        var c = DateComponents(); c.timeZone = utc
        c.year = year; c.month = month; c.day = 1
        guard let d = cal.date(from: c),
              let r = cal.range(of: .day, in: .month, for: d) else { return 31 }
        return r.count
    }

    private func clampDay() {
        let max = daysInMonth()
        if day > max { day = max }
    }

    private func syncFromDate() {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = utc
        let c = cal.dateComponents([.year, .month, .day], from: date)
        let newY = c.year ?? 2026, newM = c.month ?? 1, newD = c.day ?? 1
        if year  != newY { year  = newY }
        if month != newM { month = newM }
        if day   != newD { day   = newD }
    }

    private func pushToDate() {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = utc
        var existing = cal.dateComponents([.hour, .minute, .second], from: date)
        existing.timeZone = utc
        existing.year = year; existing.month = month; existing.day = day
        if let merged = cal.date(from: existing), abs(merged.timeIntervalSince(date)) > 0.1 {
            date = merged
        }
    }
}
