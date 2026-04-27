import SwiftUI

/// Minimal compass-rose graphic that points to the given true bearing.
struct CompassRose: View {
    let trueBearingDegrees: Double
    var color: Color = BrutalistTheme.foreground
    var accent: Color = BrutalistTheme.accent

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                Circle().stroke(color.opacity(0.6), lineWidth: 1).frame(width: s, height: s)
                Circle().stroke(color.opacity(0.3), lineWidth: 1).frame(width: s * 0.7, height: s * 0.7)
                ForEach(0..<8) { i in
                    Rectangle().fill(color.opacity(0.5))
                        .frame(width: 1, height: s * 0.05)
                        .offset(y: -s * 0.475)
                        .rotationEffect(.degrees(Double(i) * 45))
                }
                Text("N").font(.brutalistMonoBold(10)).offset(y: -s * 0.55)
                Text("S").font(.brutalistMono(10)).offset(y: s * 0.55)
                Text("E").font(.brutalistMono(10)).offset(x: s * 0.55)
                Text("W").font(.brutalistMono(10)).offset(x: -s * 0.55)
                Triangle()
                    .fill(accent)
                    .frame(width: s * 0.12, height: s * 0.45)
                    .offset(y: -s * 0.225)
                    .rotationEffect(.degrees(trueBearingDegrees))
            }
            .frame(width: s, height: s)
            .position(x: geo.size.width/2, y: geo.size.height/2)
        }
        .foregroundStyle(color)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
