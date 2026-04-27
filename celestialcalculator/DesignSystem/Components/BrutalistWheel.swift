import SwiftUI

/// Pure-SwiftUI wheel picker. No `Picker(.wheel)`, no `UIPickerView`.
///
/// Internally tracks a single continuous scroll value `scrollY` (in points,
/// 0 = first item at the centre, `(n-1)*rowHeight` = last item at the centre).
/// During a drag we update an additive `dragY` state; on release we **animate
/// both `scrollY` to the snapped target AND `dragY` back to 0 inside the same
/// `withAnimation` transaction**, so the items glide continuously from where
/// the user's finger left them to the centred position. No pop, no jump.
struct BrutalistWheel<Tag: Hashable>: View {
    @Binding var selection: Tag
    let items: [Item]
    var width: CGFloat = 64
    var rowHeight: CGFloat = 32
    var visibleRows: Int = 5

    struct Item: Hashable {
        let tag: Tag
        let title: String
    }

    /// Position of the centred row, in points (= selectedIndex × rowHeight).
    @State private var scrollY: CGFloat = 0
    /// Live drag delta in points (added to scrollY for visual position).
    @State private var dragY: CGFloat = 0
    @State private var dragInProgress: Bool = false

    private var height: CGFloat { CGFloat(visibleRows) * rowHeight }
    private var maxScroll: CGFloat { CGFloat(max(0, items.count - 1)) * rowHeight }

    private var totalScroll: CGFloat { scrollY + dragY }

    var body: some View {
        ZStack {
            // Selection band (centre row).
            Rectangle()
                .stroke(BrutalistTheme.accent, lineWidth: 1)
                .frame(width: width, height: rowHeight)

            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                let dy = CGFloat(idx) * rowHeight - totalScroll
                Text(item.title)
                    .font(.brutalistMonoBold(17))
                    .foregroundStyle(highlight(for: dy) ? BrutalistTheme.accent
                                                         : BrutalistTheme.foreground)
                    .frame(width: width, height: rowHeight)
                    .opacity(opacity(for: dy))
                    .blur(radius: blur(for: dy))
                    .offset(y: dy)
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .contentShape(Rectangle())
        .onAppear { syncScrollFromSelection(animated: false) }
        .onChange(of: selection) { _, _ in
            if !dragInProgress { syncScrollFromSelection(animated: true) }
        }
        .onChange(of: items) { _, _ in syncScrollFromSelection(animated: false) }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { v in
                    dragInProgress = true
                    let proposed = -v.translation.height
                    // Clamp so the user can't drag past the first or last row.
                    let clamped = max(-scrollY,
                                      min(maxScroll - scrollY, proposed))
                    dragY = clamped
                }
                .onEnded { v in
                    let predicted = -v.predictedEndTranslation.height
                    let target = scrollY + predicted
                    let snapped = (target / rowHeight).rounded() * rowHeight
                    let clamped = max(0, min(maxScroll, snapped))
                    let newIndex = Int((clamped / rowHeight).rounded())

                    // Sync the binding without re-entering syncScrollFromSelection
                    // (we'll handle the scroll position ourselves in this transaction).
                    let newTag = items[newIndex].tag
                    if newTag != selection { selection = newTag }

                    // Animate scrollY → snapped centre AND dragY → 0 together
                    // so the items move smoothly with no end-of-gesture pop.
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        scrollY = clamped
                        dragY = 0
                    }
                    dragInProgress = false
                }
        )
    }

    // MARK: - Visual helpers

    private func highlight(for dy: CGFloat) -> Bool { abs(dy) < 1.5 }

    private func opacity(for dy: CGFloat) -> Double {
        let dist = abs(dy) / rowHeight
        return max(0.18, 1.0 - dist * 0.28)
    }

    private func blur(for dy: CGFloat) -> CGFloat {
        let dist = abs(dy) / rowHeight
        return min(1.4, dist * 0.5)
    }

    // MARK: - Sync

    private func syncScrollFromSelection(animated: Bool) {
        guard let idx = items.firstIndex(where: { $0.tag == selection }) else { return }
        let target = CGFloat(idx) * rowHeight
        if abs(scrollY - target) < 0.5 { return }
        if animated {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                scrollY = target
                dragY = 0
            }
        } else {
            scrollY = target
            dragY = 0
        }
    }
}
