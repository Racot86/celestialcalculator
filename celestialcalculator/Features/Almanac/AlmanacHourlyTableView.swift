import SwiftUI

/// Horizontally-scrolling hourly almanac table:
/// h | Aries | Sun (GHA Dec) | Venus (GHA Dec v d) | Mars … | Jupiter … | Saturn … | Moon (GHA Dec v d HP)
struct AlmanacHourlyTableView: View {
    let hours: [AlmanacHourRow]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                headerRow
                Rectangle().fill(BrutalistTheme.foreground.opacity(0.4)).frame(height: 1)
                ForEach(hours) { row in
                    dataRow(row)
                    Rectangle().fill(BrutalistTheme.foreground.opacity(0.1)).frame(height: 1)
                }
            }
        }
    }

    // MARK: column widths
    private let wHour: CGFloat = 28
    private let wAries: CGFloat = 78
    private let wGHA: CGFloat = 78
    private let wDec: CGFloat = 80
    private let wVD: CGFloat = 38

    @ViewBuilder
    private var headerRow: some View {
        HStack(spacing: 6) {
            Text("h").frame(width: wHour, alignment: .trailing)
            cell("ARIES",   width: wAries, sub: "GHA")
            cell("SUN",     width: wGHA + wDec + 6, sub: "GHA              Dec")
            planetHeader("VENUS")
            planetHeader("MARS")
            planetHeader("JUPITER")
            planetHeader("SATURN")
            moonHeader
        }
        .font(.brutalistMono(8))
        .foregroundStyle(BrutalistTheme.muted)
        .padding(.vertical, 4)
    }

    private var moonHeader: some View {
        HStack(spacing: 4) {
            Text("MOON · GHA").frame(width: wGHA, alignment: .leading)
            Text("v").frame(width: wVD, alignment: .trailing)
            Text("Dec").frame(width: wDec, alignment: .leading)
            Text("d").frame(width: wVD, alignment: .trailing)
            Text("HP").frame(width: wVD, alignment: .trailing)
        }
    }

    private func planetHeader(_ name: String) -> some View {
        HStack(spacing: 4) {
            Text("\(name) · GHA").frame(width: wGHA, alignment: .leading)
            Text("v").frame(width: wVD, alignment: .trailing)
            Text("Dec").frame(width: wDec, alignment: .leading)
            Text("d").frame(width: wVD, alignment: .trailing)
        }
    }

    private func cell(_ label: String, width: CGFloat, sub: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label).fontWeight(.heavy)
            if let sub { Text(sub) }
        }
        .frame(width: width, alignment: .leading)
    }

    @ViewBuilder
    private func dataRow(_ row: AlmanacHourRow) -> some View {
        HStack(spacing: 6) {
            Text(String(format: "%02d", row.hour))
                .font(.brutalistMonoBold(11))
                .foregroundStyle(BrutalistTheme.accent)
                .frame(width: wHour, alignment: .trailing)
            Text(AlmanacFormat.gha(row.ghaAriesDeg))
                .frame(width: wAries, alignment: .leading)
            sunBlock(row.sun)
            planetBlock(row.venus)
            planetBlock(row.mars)
            planetBlock(row.jupiter)
            planetBlock(row.saturn)
            moonBlock(row.moon)
        }
        .font(.brutalistMono(11))
        .foregroundStyle(BrutalistTheme.foreground)
        .padding(.vertical, 3)
    }

    private func sunBlock(_ s: BodyHourly) -> some View {
        HStack(spacing: 4) {
            Text(AlmanacFormat.gha(s.ghaDeg)).frame(width: wGHA, alignment: .leading)
            Text(AlmanacFormat.dec(s.decDeg)).frame(width: wDec, alignment: .leading)
        }
    }

    private func planetBlock(_ p: BodyHourly) -> some View {
        HStack(spacing: 4) {
            Text(AlmanacFormat.gha(p.ghaDeg)).frame(width: wGHA, alignment: .leading)
            Text(AlmanacFormat.vd(p.vMinPerHour)).frame(width: wVD, alignment: .trailing)
                .foregroundStyle(BrutalistTheme.muted)
            Text(AlmanacFormat.dec(p.decDeg)).frame(width: wDec, alignment: .leading)
            Text(AlmanacFormat.vd(p.dMinPerHour)).frame(width: wVD, alignment: .trailing)
                .foregroundStyle(BrutalistTheme.muted)
        }
    }

    private func moonBlock(_ m: BodyHourly) -> some View {
        HStack(spacing: 4) {
            Text(AlmanacFormat.gha(m.ghaDeg)).frame(width: wGHA, alignment: .leading)
            Text(AlmanacFormat.vd(m.vMinPerHour)).frame(width: wVD, alignment: .trailing)
                .foregroundStyle(BrutalistTheme.muted)
            Text(AlmanacFormat.dec(m.decDeg)).frame(width: wDec, alignment: .leading)
            Text(AlmanacFormat.vd(m.dMinPerHour)).frame(width: wVD, alignment: .trailing)
                .foregroundStyle(BrutalistTheme.muted)
            Text(m.hpMin.map { String(format: "%.1f", $0) } ?? "—")
                .frame(width: wVD, alignment: .trailing)
                .foregroundStyle(BrutalistTheme.muted)
        }
    }
}
