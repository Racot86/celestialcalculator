import SwiftUI

/// Small decorative chip evoking the kanji tag in the reference image.
struct KanjiTag: View {
    var text: String = "サブジェクト"
    var subtitle: String = "HEAVY INDUSTRIES"
    var color: Color = BrutalistTheme.foreground

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.brutalistDecorative(13))
            Rectangle().fill(color).frame(width: 1, height: 14)
            Text(subtitle)
                .font(.brutalistDecorative(9))
                .kerning(0.6)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .overlay(Rectangle().stroke(color, lineWidth: 1))
        .foregroundStyle(color)
    }
}
