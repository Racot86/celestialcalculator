import SwiftUI

/// Increments and Corrections page — published-almanac analogue.
/// Top: minute selector. Middle: per-second increments for Sun/Planets and
/// Aries. Bottom: v/d correction values for the selected minute.
struct IncrementsView: View {
    @Bindable var viewModel: IncrementsViewModel

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Increments",
                       subtitle: "INCREMENTS & CORRECTIONS  •  PER MIN") {
            VStack(alignment: .leading, spacing: 12) {
                selector
                BrutalistScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        sectionTitle(String(format: "%d m  —  PER-SECOND INCREMENTS",
                                            viewModel.selectedMinute))
                        incrementsTable
                        sectionTitle("v / d  CORRECTIONS  (arc-min)")
                        correctionsTable
                    }
                    .padding(.bottom, 12)
                }
            }
        }
    }

    private var serial: String {
        String(format: "MIN %02d", viewModel.selectedMinute)
    }

    // MARK: - Selector

    private var selector: some View {
        HStack(spacing: 6) {
            stepButton("‹‹", -10)
            stepButton("‹",   -1)
            VStack(spacing: 2) {
                Text("MINUTE OF HOUR")
                    .font(.brutalistTextBold(8))
                    .foregroundStyle(BrutalistTheme.muted)
                Text(String(format: "%02d m", viewModel.selectedMinute))
                    .font(.brutalistMonoBold(20))
                    .foregroundStyle(BrutalistTheme.foreground)
            }
            .frame(maxWidth: .infinity)
            stepButton("›",    1)
            stepButton("››",  10)
        }
    }

    private func stepButton(_ label: String, _ delta: Int) -> some View {
        Button { viewModel.step(delta) } label: {
            Text(label)
                .font(.brutalistMonoBold(13))
                .foregroundStyle(BrutalistTheme.accent)
                .frame(width: 32, height: 32)
                .overlay(Rectangle().stroke(BrutalistTheme.accent, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Increments table

    private var incrementsTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("SS").frame(width: 28, alignment: .trailing)
                Text("SUN / PLANETS").frame(maxWidth: .infinity, alignment: .leading)
                Text("ARIES").frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.brutalistTextBold(8))
            .foregroundStyle(BrutalistTheme.muted)
            .padding(.vertical, 4)
            Rectangle().fill(BrutalistTheme.foreground.opacity(0.4)).frame(height: 1)

            ForEach(viewModel.incrementRows) { row in
                HStack(spacing: 6) {
                    Text(String(format: "%02d", row.seconds))
                        .font(.brutalistMonoBold(11))
                        .foregroundStyle(BrutalistTheme.accent)
                        .frame(width: 28, alignment: .trailing)
                    cell(deg: row.sunDeg, arcmin: row.sunArcmin)
                    cell(deg: row.ariesDeg, arcmin: row.ariesArcmin)
                }
                .padding(.vertical, 2)
                if row.seconds < 60 {
                    Rectangle().fill(BrutalistTheme.foreground.opacity(0.06))
                        .frame(height: 1)
                }
            }
        }
    }

    private func cell(deg: Int, arcmin: Double) -> some View {
        HStack(spacing: 4) {
            Text(String(format: "%2d°", deg))
                .font(.brutalistMono(11))
                .foregroundStyle(BrutalistTheme.foreground)
                .frame(width: 30, alignment: .trailing)
            Text(String(format: "%4.1f'", arcmin))
                .font(.brutalistMonoBold(11))
                .foregroundStyle(BrutalistTheme.foreground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Corrections table

    private var correctionsTable: some View {
        let rows = viewModel.correctionRows
        // Two-column layout to compress vertical space — first half on the
        // left, second half on the right (matches the printed v/d block).
        let half = (rows.count + 1) / 2
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                correctionsHeader.frame(maxWidth: .infinity, alignment: .leading)
                correctionsHeader.frame(maxWidth: .infinity, alignment: .leading)
            }
            Rectangle().fill(BrutalistTheme.foreground.opacity(0.4)).frame(height: 1)
            ForEach(0..<half, id: \.self) { i in
                HStack(spacing: 8) {
                    correctionRow(rows[i])
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if half + i < rows.count {
                        correctionRow(rows[half + i])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var correctionsHeader: some View {
        HStack(spacing: 4) {
            Text("v / d").frame(width: 60, alignment: .leading)
            Text("CORR").frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.brutalistTextBold(8))
        .foregroundStyle(BrutalistTheme.muted)
        .padding(.vertical, 4)
    }

    private func correctionRow(_ row: CorrectionRow) -> some View {
        HStack(spacing: 4) {
            Text(String(format: "%4.1f'", row.v))
                .font(.brutalistMono(11))
                .foregroundStyle(BrutalistTheme.muted)
                .frame(width: 60, alignment: .leading)
            Text(String(format: "%4.1f'", row.correction))
                .font(.brutalistMonoBold(11))
                .foregroundStyle(BrutalistTheme.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionTitle(_ s: String) -> some View {
        Text(s)
            .font(.brutalistTextBold(10))
            .foregroundStyle(BrutalistTheme.accent)
    }
}
