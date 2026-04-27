import SwiftUI

/// Custom brutalist toggle. Hard rectangles, no system pill or thumb halo,
/// no liquid-glass material. Animates the thumb across two discrete states.
struct BrutalistToggle: View {
    @Binding var isOn: Bool
    let label: String

    private let trackWidth: CGFloat = 54
    private let trackHeight: CGFloat = 26
    private let thumbInset: CGFloat = 3

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.12)) { isOn.toggle() }
        } label: {
            HStack(spacing: 12) {
                Text(label.uppercased())
                    .font(.brutalistText(11))
                    .foregroundStyle(BrutalistTheme.foreground)
                Spacer()
                trackView
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var trackView: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            // Track
            Rectangle()
                .fill(isOn ? BrutalistTheme.accent : BrutalistTheme.background)
                .frame(width: trackWidth, height: trackHeight)
                .overlay(
                    Rectangle()
                        .stroke(BrutalistTheme.foreground, lineWidth: 1.5)
                )
            // Thumb
            Rectangle()
                .fill(isOn ? BrutalistTheme.background : BrutalistTheme.foreground)
                .frame(width: trackHeight - thumbInset * 2,
                       height: trackHeight - thumbInset * 2)
                .padding(thumbInset)
        }
        .frame(width: trackWidth, height: trackHeight)
    }
}
