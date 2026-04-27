import SwiftUI

struct CornerRegistrationMarks: View {
    var color: Color
    var armLength: CGFloat = 14
    var thickness: CGFloat = 2
    var inset: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                bracket().position(x: inset + armLength/2, y: inset + thickness/2)
                bracket().rotationEffect(.degrees(0))
                    .position(x: inset + thickness/2, y: inset + armLength/2)
                bracket().position(x: w - inset - armLength/2, y: inset + thickness/2)
                bracket().position(x: w - inset - thickness/2, y: inset + armLength/2)
                bracket().position(x: inset + armLength/2, y: h - inset - thickness/2)
                bracket().position(x: inset + thickness/2, y: h - inset - armLength/2)
                bracket().position(x: w - inset - armLength/2, y: h - inset - thickness/2)
                bracket().position(x: w - inset - thickness/2, y: h - inset - armLength/2)
            }
        }
        .allowsHitTesting(false)
    }

    private func bracket() -> some View {
        Rectangle().fill(color).frame(width: armLength, height: thickness)
    }
}
