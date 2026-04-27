import SwiftUI

struct BodyRowView: View {
    let row: BodyAzimuthRow

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
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
                Text(AngleFormatting.bearing(row.azimuthDegrees))
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
}
