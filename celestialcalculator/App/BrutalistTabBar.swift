import SwiftUI

/// Terminal-style brutalist tab bar. No icons, no pills, no Material accent
/// stripe — just text labels separated by hard vertical rules. The active tab
/// is shown in the accent colour with a thick underline; inactive labels are
/// muted. Background extends through the home-indicator safe area.
struct BrutalistTabBar<Selection: Hashable>: View {
    @Binding var selection: Selection
    let items: [Item]

    struct Item: Identifiable {
        let id: Selection
        let title: String
    }

    private let barHeight: CGFloat = 52

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(BrutalistTheme.foreground.opacity(0.5))
                .frame(height: 2)
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                    if idx > 0 {
                        Rectangle()
                            .fill(BrutalistTheme.foreground.opacity(0.35))
                            .frame(width: 1, height: 26)
                    }
                    button(for: item)
                }
            }
            .frame(height: barHeight)
        }
        .background(BrutalistTheme.background.ignoresSafeArea(edges: .bottom))
    }

    private func button(for item: Item) -> some View {
        let active = item.id == selection
        return Button {
            selection = item.id
        } label: {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Text(item.title.uppercased())
                    .font(.brutalistLabel(active ? 12 : 11))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 4)
                    .foregroundStyle(active ? BrutalistTheme.accent : BrutalistTheme.muted)
                Spacer(minLength: 0)
                Rectangle()
                    .fill(active ? BrutalistTheme.accent : Color.clear)
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
