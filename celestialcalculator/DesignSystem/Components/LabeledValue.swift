import SwiftUI

struct LabeledValue: View {
    let label: String
    let value: String
    var alignment: HorizontalAlignment = .leading
    var labelColor: Color = BrutalistTheme.muted
    var valueColor: Color = BrutalistTheme.foreground
    var valueFont: Font = .brutalistMonoBold(15)

    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(label.uppercased())
                .font(.brutalistMono(9))
                .foregroundStyle(labelColor)
            Text(value)
                .font(valueFont)
                .foregroundStyle(valueColor)
        }
    }
}
