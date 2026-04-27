import SwiftUI

struct ChartView: View {
    @Bindable var viewModel: ChartViewModel

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Sky Chart",
                       subtitle: "AZ × ALT  •  90° WINDOW") {
            VStack(alignment: .leading, spacing: 12) {
                TimeStrip(date: viewModel.observerStore.observer.date)
                panBar
                ChartCanvas(viewModel: viewModel)
                    .frame(maxHeight: .infinity)
                legend
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var panBar: some View {
        HStack(spacing: 8) {
            stepButton(label: "‹‹", delta: -3)
            stepButton(label: "‹",  delta: -1)
            VStack(spacing: 2) {
                Text("AZIMUTH WINDOW")
                    .font(.brutalistTextBold(8))
                    .foregroundStyle(BrutalistTheme.muted)
                Text(windowLabel)
                    .font(.brutalistMonoBold(15))
                    .foregroundStyle(BrutalistTheme.foreground)
            }
            .frame(maxWidth: .infinity)
            stepButton(label: "›",  delta:  1)
            stepButton(label: "››", delta:  3)
            Button { viewModel.centerOnBrightest() } label: {
                Text("FIT")
                    .font(.brutalistTextBold(10))
                    .padding(.horizontal, 8).padding(.vertical, 6)
                    .background(BrutalistTheme.accent)
                    .foregroundStyle(BrutalistTheme.background)
            }
            .buttonStyle(.plain)
        }
    }

    private func stepButton(label: String, delta: Int) -> some View {
        Button { viewModel.step(delta) } label: {
            Text(label)
                .font(.brutalistMonoBold(13))
                .foregroundStyle(BrutalistTheme.accent)
                .frame(width: 30, height: 30)
                .background(BrutalistTheme.background)
                .overlay(Rectangle().stroke(BrutalistTheme.accent, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var windowLabel: String {
        let start = viewModel.windowStartDeg
        let end = (start + viewModel.windowWidthDeg)
            .truncatingRemainder(dividingBy: 360)
        return String(format: "%05.1f°  ―  %05.1f°", start, end)
    }

    private var legend: some View {
        let count = viewModel.visibleBodies.count
        let inWin = viewModel.bodiesInWindow().count
        return HStack {
            Text("\(count) BODIES ABOVE HORIZON")
                .font(.brutalistText(9))
                .foregroundStyle(BrutalistTheme.muted)
            Spacer()
            Text("IN WINDOW: \(inWin)")
                .font(.brutalistTextBold(9))
                .foregroundStyle(BrutalistTheme.accent)
        }
    }

    private var serial: String {
        String(format: "AZ %.0f°", viewModel.windowStartDeg)
    }
}

private struct ChartCanvas: View {
    let viewModel: ChartViewModel

    @GestureState private var dragDeg: Double = 0
    /// Snapshot of windowStartDeg at the moment a drag begins.
    @State private var dragStartWindow: Double = 0

    private let leftPad: CGFloat = 36
    private let bottomPad: CGFloat = 22
    private let topPad: CGFloat = 6
    private let rightPad: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            let plotWidth = max(0, geo.size.width - leftPad - rightPad)
            let plotHeight = max(0, geo.size.height - topPad - bottomPad)

            ZStack(alignment: .topLeading) {
                gridLayer(plotWidth: plotWidth, plotHeight: plotHeight)
                    .offset(x: leftPad, y: topPad)
                axisLabels(plotWidth: plotWidth, plotHeight: plotHeight,
                           totalSize: geo.size)
                bodiesLayer(plotWidth: plotWidth, plotHeight: plotHeight)
                    .offset(x: leftPad, y: topPad)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { v in
                        if dragDeg == 0 { dragStartWindow = viewModel.windowStartDeg }
                        // Drag-left → window moves to higher azimuths (positive delta).
                        let degreesPerPoint = viewModel.windowWidthDeg / max(1, plotWidth)
                        let delta = -v.translation.width * degreesPerPoint
                        var next = dragStartWindow + delta
                        next = ((next.truncatingRemainder(dividingBy: 360)) + 360)
                                  .truncatingRemainder(dividingBy: 360)
                        viewModel.windowStartDeg = next
                    }
                    .updating($dragDeg) { v, state, _ in
                        state = -v.translation.width
                    }
            )
        }
    }

    private func gridLayer(plotWidth: CGFloat, plotHeight: CGFloat) -> some View {
        Canvas { ctx, _ in
            for i in 0...9 {
                let x = plotWidth * CGFloat(i) / 9.0
                var p = Path()
                p.move(to: CGPoint(x: x, y: 0))
                p.addLine(to: CGPoint(x: x, y: plotHeight))
                let isMajor = i == 0 || i == 9
                ctx.stroke(p, with: .color(BrutalistTheme.foreground
                    .opacity(isMajor ? 0.35 : 0.12)), lineWidth: isMajor ? 1 : 0.5)
            }
            for i in 0...9 {
                let alt = Double(i) * 10
                let y = plotHeight * (1.0 - alt / 90.0)
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: plotWidth, y: y))
                let isMajor = (i == 0 || i == 9)
                ctx.stroke(p, with: .color(BrutalistTheme.foreground
                    .opacity(isMajor ? 0.35 : 0.12)), lineWidth: isMajor ? 1 : 0.5)
            }
        }
        .frame(width: plotWidth, height: plotHeight)
    }

    private func axisLabels(plotWidth: CGFloat, plotHeight: CGFloat,
                            totalSize: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach([0, 30, 60, 90], id: \.self) { alt in
                let y = topPad + plotHeight * CGFloat(1.0 - Double(alt) / 90.0)
                Text("\(alt)°")
                    .font(.brutalistMono(9))
                    .foregroundStyle(BrutalistTheme.muted)
                    .frame(width: leftPad - 4, alignment: .trailing)
                    .position(x: (leftPad - 4) / 2, y: y)
            }
            let start = viewModel.windowStartDeg
            ForEach(0..<4, id: \.self) { i in
                let frac = CGFloat(i) / 3.0
                let azDeg = (start + Double(i) * 30.0)
                    .truncatingRemainder(dividingBy: 360)
                let x = leftPad + frac * plotWidth
                let y = topPad + plotHeight + bottomPad / 2
                VStack(spacing: 1) {
                    Text(String(format: "%05.1f°", azDeg))
                        .font(.brutalistMono(9))
                        .foregroundStyle(BrutalistTheme.muted)
                    Text(AngleFormatting.cardinal(azDeg))
                        .font(.brutalistTextBold(8))
                        .foregroundStyle(BrutalistTheme.accent)
                }
                .position(x: x, y: y)
            }
        }
        .frame(width: totalSize.width, height: totalSize.height)
        .allowsHitTesting(false)
    }

    private func bodiesLayer(plotWidth: CGFloat, plotHeight: CGFloat) -> some View {
        let entries = viewModel.bodiesInWindow()
        return ZStack(alignment: .topLeading) {
            ForEach(entries, id: \.body.id) { entry in
                bodyMarker(entry: entry,
                           x: CGFloat(entry.relX) * plotWidth,
                           y: plotHeight * CGFloat(1.0 - entry.body.altitudeDeg / 90.0))
            }
        }
        .frame(width: plotWidth, height: plotHeight)
    }

    private func bodyMarker(entry: (body: ChartBody, relX: Double),
                            x: CGFloat, y: CGFloat) -> some View {
        let isLuminary = (entry.body.bodyID == .sun || entry.body.bodyID == .moon)
        let isPlanet: Bool = {
            if case .planet = entry.body.bodyID { return true }
            return false
        }()
        let dotSize: CGFloat = isLuminary ? 12 : (isPlanet ? 9 : 6)
        return NavigationLink(value: entry.body.bodyID) {
            ZStack {
                Rectangle()
                    .fill(BrutalistTheme.accent)
                    .frame(width: dotSize, height: dotSize)
                    .overlay(Rectangle().stroke(BrutalistTheme.background, lineWidth: 1))
                Text(entry.body.displayName.uppercased())
                    .font(.brutalistTextBold(9))
                    .foregroundStyle(BrutalistTheme.foreground)
                    .padding(.horizontal, 2)
                    .background(BrutalistTheme.background.opacity(0.85))
                    .offset(y: -dotSize - 6)
            }
            // Pad the hit area so taps register on the label too, without
            // letting the pad block panning gestures elsewhere on the canvas.
            .frame(width: max(40, dotSize + 24), height: dotSize + 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .position(x: x, y: y)
    }
}
