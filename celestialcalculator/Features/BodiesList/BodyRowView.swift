import SwiftUI

struct BodyRowView: View {
    let row: BodyAzimuthRow

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(row.bodyID.symbol)
                .font(symbolFont)
                .foregroundStyle(BrutalistTheme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: 64, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                Text(row.displayName.uppercased())
                    .font(.brutalistLabel(13))
                    .foregroundStyle(BrutalistTheme.foreground)
                Text(row.classification)
                    .font(.brutalistMono(8))
                    .foregroundStyle(BrutalistTheme.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text(String(format: "%05.1f°", normalizedAz))
                    .font(.brutalistMonoBold(15))
                    .foregroundStyle(isAboveHorizon ? BrutalistTheme.accent : BrutalistTheme.muted)
                Text("\(AngleFormatting.cardinal(row.azimuthDegrees)) • alt \(AngleFormatting.altitude(row.altitudeDegrees))")
                    .font(.brutalistMono(9))
                    .foregroundStyle(BrutalistTheme.muted)
            }
        }
        .padding(.vertical, 6)
        .opacity(isAboveHorizon ? 1.0 : 0.55)
    }

    private var isAboveHorizon: Bool { row.altitudeDegrees > 0 }

    /// Sun/Moon/planet glyphs are single graphemes — render them larger.
    /// Star Bayer designations are 4–6 characters — slightly smaller so they fit.
    private var symbolFont: Font {
        if case .star = row.bodyID {
            return .system(size: 13, weight: .heavy, design: .serif)
        }
        return .system(size: 22, weight: .regular)
    }

    private var normalizedAz: Double {
        let n = row.azimuthDegrees.truncatingRemainder(dividingBy: 360.0)
        return n < 0 ? n + 360.0 : n
    }
}
