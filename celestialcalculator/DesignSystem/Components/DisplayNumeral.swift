import SwiftUI

/// Oversized geometric numeric display, like the "B2" / "T-972" hero numerals.
struct DisplayNumeral: View {
    let text: String
    var color: Color = BrutalistTheme.accent
    var size: CGFloat = 140

    var body: some View {
        Text(text)
            .font(.brutalistDisplay(size))
            .foregroundStyle(color)
            .kerning(-2)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
    }
}
