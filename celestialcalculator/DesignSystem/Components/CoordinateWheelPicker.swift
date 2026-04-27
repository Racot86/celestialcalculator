import SwiftUI

enum CoordinateAxis {
    case latitude, longitude

    var maxDegrees: Int { self == .latitude ? 89 : 179 }
    var positiveHemisphere: String { self == .latitude ? "N" : "E" }
    var negativeHemisphere: String { self == .latitude ? "S" : "W" }
    var degreeWidth: Int { self == .latitude ? 2 : 3 }
}

/// Single-gesture-per-component picker. Each wheel moves with one swipe.
/// Format: DD-MM.M' N/S  /  DDD-MM.M' E/W
struct CoordinateWheelPicker: View {
    let axis: CoordinateAxis
    /// Signed value in decimal degrees. North/East positive.
    @Binding var value: Double

    @State private var deg: Int = 0
    @State private var min: Int = 0
    @State private var tenth: Int = 0
    @State private var positive: Bool = true

    private let wheelHeight: CGFloat = 110

    var body: some View {
        HStack(spacing: 0) {
            wheel(label: "DEG",
                  selection: $deg,
                  range: 0...axis.maxDegrees,
                  format: "%0\(axis.degreeWidth)d°")
            wheel(label: "MIN",
                  selection: $min,
                  range: 0...59,
                  format: "%02d")
            wheel(label: "TENTHS",
                  selection: $tenth,
                  range: 0...9,
                  format: ".%d'")
            hemisphereWheel
        }
        .frame(height: wheelHeight + 18)
        .onAppear { syncFromValue() }
        .onChange(of: value) { _, _ in syncFromValue() }
        .onChange(of: deg)      { _, _ in pushToValue() }
        .onChange(of: min)      { _, _ in pushToValue() }
        .onChange(of: tenth)    { _, _ in pushToValue() }
        .onChange(of: positive) { _, _ in pushToValue() }
    }

    private func wheel(label: String,
                       selection: Binding<Int>,
                       range: ClosedRange<Int>,
                       format: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.brutalistMono(8))
                .foregroundStyle(BrutalistTheme.muted)
            Picker(label, selection: selection) {
                ForEach(Array(range), id: \.self) { v in
                    Text(String(format: format, v))
                        .font(.brutalistMonoBold(17))
                        .foregroundStyle(BrutalistTheme.foreground)
                        .tag(v)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: wheelHeight)
            .clipped()
        }
    }

    private var hemisphereWheel: some View {
        VStack(spacing: 2) {
            Text("HEM")
                .font(.brutalistMono(8))
                .foregroundStyle(BrutalistTheme.muted)
            Picker("Hemisphere", selection: $positive) {
                Text(axis.positiveHemisphere)
                    .font(.brutalistMonoBold(17))
                    .foregroundStyle(BrutalistTheme.accent)
                    .tag(true)
                Text(axis.negativeHemisphere)
                    .font(.brutalistMonoBold(17))
                    .foregroundStyle(BrutalistTheme.accent)
                    .tag(false)
            }
            .pickerStyle(.wheel)
            .frame(height: wheelHeight)
            .clipped()
        }
    }

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
        if min != fixedM { min = fixedM }
        if tenth != fixedT { tenth = fixedT }
        let pos = value >= 0
        if positive != pos { positive = pos }
    }

    private func pushToValue() {
        let mag = Double(deg) + Double(min)/60.0 + Double(tenth)/600.0
        let signed = positive ? mag : -mag
        if abs(signed - value) > 1e-9 {
            value = signed
        }
    }
}
