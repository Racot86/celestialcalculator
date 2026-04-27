import SwiftUI

struct BarcodeStripe: View {
    var color: Color
    var seed: UInt64 = 7274
    var height: CGFloat = 26

    var body: some View {
        Canvas { context, size in
            var rng = SeededRandom(seed: seed)
            var x: CGFloat = 0
            while x < size.width {
                let w = CGFloat(rng.nextInt(in: 1...4))
                let isBar = rng.nextBool()
                if isBar {
                    let rect = CGRect(x: x, y: 0, width: w, height: size.height)
                    context.fill(Path(rect), with: .color(color))
                }
                x += w
            }
        }
        .frame(height: height)
    }
}

private struct SeededRandom {
    var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0xDEAD_BEEF : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
    mutating func nextInt(in range: ClosedRange<Int>) -> Int {
        let span = UInt64(range.upperBound - range.lowerBound + 1)
        return Int(next() % span) + range.lowerBound
    }
    mutating func nextBool() -> Bool { next() & 1 == 0 }
}
