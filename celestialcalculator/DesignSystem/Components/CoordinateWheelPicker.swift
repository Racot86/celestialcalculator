import SwiftUI

enum CoordinateAxis {
    case latitude, longitude

    var maxDegrees: Int { self == .latitude ? 89 : 179 }
    var positiveHemisphere: String { self == .latitude ? "N" : "E" }
    var negativeHemisphere: String { self == .latitude ? "S" : "W" }
    var degreeWidth: Int { self == .latitude ? 2 : 3 }
}

/// Coordinate picker — uses the custom-SwiftUI `BrutalistWheel`.
/// Format: DD°MM.M' N/S  /  DDD°MM.M' E/W
struct CoordinateWheelPicker: View {
    let axis: CoordinateAxis
    @Binding var value: Double

    @State private var deg: Int = 0
    @State private var min: Int = 0
    @State private var tenth: Int = 0
    @State private var positive: Bool = true

    var body: some View {
        // The HStack hugs the wheels and is centred by its parent — no Spacer
        // splits the row, no gap between label and wheels.
        HStack(spacing: 6) {
            column(label: "DEG",
                   binding: $deg,
                   items: degItems,
                   width: axis == .latitude ? 70 : 80)
            column(label: "MIN",
                   binding: $min,
                   items: minItems,
                   width: 60)
            column(label: "TENTHS",
                   binding: $tenth,
                   items: tenthItems,
                   width: 64)
            column(label: "HEM",
                   binding: $positive,
                   items: hemItems,
                   width: 56)
        }
        .frame(maxWidth: .infinity)
        .onAppear { syncFromValue() }
        .onChange(of: value)    { _, _ in syncFromValue() }
        .onChange(of: deg)      { _, _ in pushToValue() }
        .onChange(of: min)      { _, _ in pushToValue() }
        .onChange(of: tenth)    { _, _ in pushToValue() }
        .onChange(of: positive) { _, _ in pushToValue() }
    }

    private func column<Tag: Hashable>(label: String,
                                       binding: Binding<Tag>,
                                       items: [BrutalistWheel<Tag>.Item],
                                       width: CGFloat) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.brutalistTextBold(8))
                .foregroundStyle(BrutalistTheme.muted)
            BrutalistWheel(selection: binding, items: items, width: width)
        }
    }

    // MARK: - Item providers

    private var degItems: [BrutalistWheel<Int>.Item] {
        let fmt = "%0\(axis.degreeWidth)d°"
        return (0...axis.maxDegrees).map { .init(tag: $0, title: String(format: fmt, $0)) }
    }
    private var minItems: [BrutalistWheel<Int>.Item] {
        (0...59).map { .init(tag: $0, title: String(format: "%02d", $0)) }
    }
    private var tenthItems: [BrutalistWheel<Int>.Item] {
        (0...9).map { .init(tag: $0, title: String(format: ".%d'", $0)) }
    }
    private var hemItems: [BrutalistWheel<Bool>.Item] {
        [.init(tag: true,  title: axis.positiveHemisphere),
         .init(tag: false, title: axis.negativeHemisphere)]
    }

    // MARK: - Value sync

    private func syncFromValue() {
        let absValue = abs(value)
        let d = Int(floor(absValue))
        let totalMinutes = (absValue - Double(d)) * 60.0
        let m = Int(floor(totalMinutes))
        let t = Int(((totalMinutes - Double(m)) * 10.0).rounded())
        let (carryM, fixedT) = t == 10 ? (1, 0) : (0, t)
        let (carryD, fixedM) = (m + carryM) == 60 ? (1, 0) : (0, m + carryM)
        let fixedD = Swift.min(d + carryD, axis.maxDegrees)

        if deg != fixedD { deg = fixedD }
        if self.min != fixedM { self.min = fixedM }
        if tenth != fixedT { tenth = fixedT }
        let pos = value >= 0
        if positive != pos { positive = pos }
    }

    private func pushToValue() {
        let mag = Double(deg) + Double(min) / 60.0 + Double(tenth) / 600.0
        let signed = positive ? mag : -mag
        if abs(signed - value) > 1e-9 { value = signed }
    }
}
