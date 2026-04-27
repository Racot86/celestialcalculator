import SwiftUI

struct ChartView: View {
    @Bindable var viewModel: ChartViewModel
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            BrutalistPanel(serial: serial,
                           title: "Sky Chart",
                           subtitle: "AZ × ALT  •  90° WINDOW") {
                VStack(alignment: .leading, spacing: 12) {
                    TimeStrip(date: viewModel.observerStore.observer.date)
                    panBar
                    ChartCanvas(viewModel: viewModel) { id in
                        path.append(id)
                    }
                    .frame(maxHeight: .infinity)
                    legend
                }
            }
            .navigationDestination(for: CelestialBodyID.self) { id in
                BodyDetailView(viewModel:
                    BodyDetailViewModel(bodyID: id,
                                        observerStore: viewModel.observerStore))
            }
            .toolbar(.hidden, for: .navigationBar)
        }
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
    let onTapBody: (CelestialBodyID) -> Void

    /// Window-start snapshot at the moment a drag begins.
    @State private var dragStartWindow: Double = 0
    @State private var dragMoved: CGFloat = 0

    private let leftPad: CGFloat = 36
    private let bottomPad: CGFloat = 22
    private let topPad: CGFloat = 6
    private let rightPad: CGFloat = 6
    /// Touches that travel less than this in points are treated as taps.
    private let tapSlop: CGFloat = 6
    /// Body marker hit radius for tap detection.
    private let tapHitRadius: CGFloat = 22

    var body: some View {
        GeometryReader { geo in
            let plotWidth = max(0, geo.size.width - leftPad - rightPad)
            let plotHeight = max(0, geo.size.height - topPad - bottomPad)

            ZStack(alignment: .topLeading) {
                gridLayer(plotWidth: plotWidth, plotHeight: plotHeight)
                    .offset(x: leftPad, y: topPad)
                bodiesLayer(plotWidth: plotWidth, plotHeight: plotHeight)
                    .offset(x: leftPad, y: topPad)
                axisLabels(plotWidth: plotWidth, plotHeight: plotHeight,
                           totalSize: geo.size)
            }
            .contentShape(Rectangle())
            // ONE gesture for the whole canvas. We dispatch to pan vs. tap
            // based on cumulative movement at gesture-end. This eliminates
            // the recogniser race between marker tap gestures and the canvas
            // drag — touches starting on a body still produce smooth pan.
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        if dragMoved == 0 { dragStartWindow = viewModel.windowStartDeg }
                        let dist = hypot(v.translation.width, v.translation.height)
                        dragMoved = max(dragMoved, dist)
                        // Only commit a pan once the touch crosses the tap-slop
                        // threshold. Inside the slop, treat as a still touch.
                        if dragMoved >= tapSlop {
                            updatePan(translationX: v.translation.width,
                                      plotWidth: plotWidth)
                        }
                    }
                    .onEnded { v in
                        defer { dragMoved = 0 }
                        if dragMoved < tapSlop {
                            // Treat as tap — hit-test against body markers.
                            let local = CGPoint(x: v.startLocation.x - leftPad,
                                                y: v.startLocation.y - topPad)
                            if let id = hitTestBody(at: local,
                                                    plotWidth: plotWidth,
                                                    plotHeight: plotHeight) {
                                onTapBody(id)
                            }
                        } else {
                            updatePan(translationX: v.translation.width,
                                      plotWidth: plotWidth)
                        }
                    }
            )
        }
    }

    private func updatePan(translationX dx: CGFloat, plotWidth: CGFloat) {
        let degreesPerPoint = viewModel.windowWidthDeg / max(1, plotWidth)
        let delta = -dx * degreesPerPoint
        let next = (dragStartWindow + delta).rounded()                       // 1° snap
        let wrapped = ((next.truncatingRemainder(dividingBy: 360)) + 360)
                          .truncatingRemainder(dividingBy: 360)
        if abs(wrapped - viewModel.windowStartDeg) > 0.01 {
            viewModel.windowStartDeg = wrapped
        }
    }

    /// Find the closest body marker to a tap point in plot-local coordinates,
    /// within `tapHitRadius`. Returns the body id, or nil if no hit.
    private func hitTestBody(at point: CGPoint,
                             plotWidth: CGFloat,
                             plotHeight: CGFloat) -> CelestialBodyID? {
        let entries = viewModel.bodiesInWindow()
        var best: (id: CelestialBodyID, distSq: CGFloat)? = nil
        for entry in entries {
            let bx = CGFloat(entry.relX) * plotWidth
            let by = plotHeight * CGFloat(1.0 - entry.body.altitudeDeg / 90.0)
            let dx = bx - point.x, dy = by - point.y
            let dsq = dx*dx + dy*dy
            if dsq <= tapHitRadius * tapHitRadius {
                if best == nil || dsq < best!.distSq {
                    best = (entry.body.bodyID, dsq)
                }
            }
        }
        return best?.id
    }

    // MARK: - Layers

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
        .allowsHitTesting(false)
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
        // Markers are pure display — touches are handled exclusively by the
        // canvas-level gesture above. No nested gestures, no recogniser race.
        .allowsHitTesting(false)
    }

    private func bodyMarker(entry: (body: ChartBody, relX: Double),
                            x: CGFloat, y: CGFloat) -> some View {
        let isLuminary = (entry.body.bodyID == .sun || entry.body.bodyID == .moon)
        let isPlanet: Bool = {
            if case .planet = entry.body.bodyID { return true }
            return false
        }()
        let dotSize: CGFloat = isLuminary ? 12 : (isPlanet ? 9 : 6)
        return ZStack {
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
        .position(x: x, y: y)
    }
}
