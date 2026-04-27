import SwiftUI

/// Brutalist scanning-bar loader. Five rectangular bars whose heights pulse in
/// sequence — looks like a hardware spectrum analyser. Driven by `TimelineView`
/// so it animates without view-state churn.
struct BrutalistLoader: View {
    var label: String = "COMPUTING…"
    var barCount: Int = 7

    var body: some View {
        VStack(spacing: 14) {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { ctx in
                let t = ctx.date.timeIntervalSinceReferenceDate
                HStack(alignment: .center, spacing: 5) {
                    ForEach(0..<barCount, id: \.self) { i in
                        Rectangle()
                            .fill(BrutalistTheme.accent)
                            .frame(width: 7, height: barHeight(time: t, index: i))
                    }
                }
                .frame(height: 48)
            }
            Text(label)
                .font(.brutalistDecorative(13))
                .foregroundStyle(BrutalistTheme.muted)
                .kerning(2)
        }
    }

    private func barHeight(time t: TimeInterval, index i: Int) -> CGFloat {
        let phase = t * 1.4 + Double(i) * 0.22
        let s = (sin(phase * 2 * .pi) + 1) / 2          // 0…1
        let eased = pow(s, 1.6)
        return 8 + CGFloat(eased) * 36
    }
}
