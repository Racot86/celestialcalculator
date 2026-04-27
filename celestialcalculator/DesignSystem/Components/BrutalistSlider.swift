import SwiftUI

/// Drawn-from-scratch slider — no system control, no glass, no halos. Just a
/// thin rectangular track, a filled portion, and a square thumb. The drag
/// gesture writes directly to a value bound, snapped to `step`.
struct BrutalistSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1

    private let trackHeight: CGFloat = 2
    private let thumbWidth: CGFloat = 12
    private let thumbHeight: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let span = range.upperBound - range.lowerBound
            let frac = span > 0 ? (value - range.lowerBound) / span : 0
            let thumbX = CGFloat(frac) * (width - thumbWidth) + thumbWidth / 2

            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(BrutalistTheme.foreground.opacity(0.25))
                    .frame(height: trackHeight)
                // Filled portion (left of the thumb)
                Rectangle()
                    .fill(BrutalistTheme.accent)
                    .frame(width: max(0, thumbX - thumbWidth / 2), height: trackHeight)
                // Square thumb
                Rectangle()
                    .fill(BrutalistTheme.accent)
                    .frame(width: thumbWidth, height: thumbHeight)
                    .overlay(Rectangle().stroke(BrutalistTheme.background, lineWidth: 2))
                    .offset(x: thumbX - thumbWidth / 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let usable = max(1, width - thumbWidth)
                        let xClamped = max(thumbWidth / 2,
                                           min(width - thumbWidth / 2, drag.location.x))
                        let f = (xClamped - thumbWidth / 2) / usable
                        var v = range.lowerBound + Double(f) * span
                        if step > 0 { v = (v / step).rounded() * step }
                        value = max(range.lowerBound, min(range.upperBound, v))
                    }
            )
        }
        .frame(height: thumbHeight)
    }
}
