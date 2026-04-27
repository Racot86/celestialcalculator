import SwiftUI

/// Vertical scroll view with **no visible scroll bar**. The only indication
/// that the content is scrollable is a soft fade at the edges in the panel
/// background colour — present only on the side(s) that have more content
/// beyond the viewport, hidden at the extremes so nothing obscures content
/// when the user has reached the top or bottom.
struct BrutalistScrollView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    @State private var offsetY: CGFloat = 0

    private let edgeFade: CGFloat = 18

    var body: some View {
        ScrollView(showsIndicators: false) {
            content()
                // iOS 18 `onGeometryChange` updates state outside the render
                // pass, avoiding the "preference updated multiple times per
                // frame" warning that PreferenceKey-based measurement causes.
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { newHeight in
                    contentHeight = newHeight
                }
        }
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: ScrollSnapshot.self) { geo in
            ScrollSnapshot(offset: geo.contentOffset.y,
                           viewport: geo.containerSize.height)
        } action: { _, snap in
            offsetY = snap.offset
            viewportHeight = snap.viewport
        }
        .overlay(alignment: .top) {
            fade(.top)
                .opacity(canScrollUp ? 1 : 0)
                .animation(.easeOut(duration: 0.15), value: canScrollUp)
        }
        .overlay(alignment: .bottom) {
            fade(.bottom)
                .opacity(canScrollDown ? 1 : 0)
                .animation(.easeOut(duration: 0.15), value: canScrollDown)
        }
    }

    private var canScrollUp: Bool { offsetY > 0.5 }
    private var canScrollDown: Bool {
        contentHeight > viewportHeight + 0.5 &&
        offsetY < (contentHeight - viewportHeight) - 0.5
    }

    private func fade(_ edge: Edge) -> some View {
        let stops: [Gradient.Stop] = edge == .top
            ? [.init(color: BrutalistTheme.background, location: 0),
               .init(color: BrutalistTheme.background.opacity(0), location: 1)]
            : [.init(color: BrutalistTheme.background.opacity(0), location: 0),
               .init(color: BrutalistTheme.background, location: 1)]
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
            .frame(height: edgeFade)
            .allowsHitTesting(false)
    }
}

private struct ScrollSnapshot: Equatable {
    let offset: CGFloat
    let viewport: CGFloat
}
