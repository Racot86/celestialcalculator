import SwiftUI

/// Modal sheet hosting the coordinate wheel picker for a single axis.
///
/// The wheel writes into a *local draft* — only when the user taps DONE do we
/// commit back to the observer's value. This keeps every astronomy computation
/// in the rest of the app from rerunning on every wheel tick (which made the
/// picker feel laggy).
struct CoordinateSheet: View {
    let axis: CoordinateAxis
    @Binding var value: Double
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Double = 0
    @State private var didLoad = false

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: title,
                       subtitle: subtitle) {
            VStack(alignment: .leading, spacing: 18) {
                CoordinateWheelPicker(axis: axis, value: $draft)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("CANCEL")
                            .font(.brutalistMonoBold(12))
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .foregroundStyle(BrutalistTheme.foreground)
                            .overlay(Rectangle().stroke(BrutalistTheme.foreground, lineWidth: 1))
                    }
                    Spacer()
                    Button {
                        value = draft
                        dismiss()
                    } label: {
                        Text("DONE")
                            .font(.brutalistMonoBold(12))
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(BrutalistTheme.accent)
                            .foregroundStyle(BrutalistTheme.background)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onAppear {
            if !didLoad { draft = value; didLoad = true }
        }
    }

    private var title: String { axis == .latitude ? "Latitude" : "Longitude" }
    private var subtitle: String { axis == .latitude ? "DD°MM.M' N/S" : "DDD°MM.M' E/W" }
    private var serial: String {
        axis == .latitude
            ? AngleFormatting.latitudeCompact(draft)
            : AngleFormatting.longitudeCompact(draft)
    }
}
