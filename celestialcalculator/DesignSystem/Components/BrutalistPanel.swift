import SwiftUI

struct BrutalistPanel<Content: View>: View {
    let serial: String
    let title: String
    let subtitle: String?
    @ViewBuilder let content: () -> Content

    init(serial: String,
         title: String,
         subtitle: String? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.serial = serial
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            BrutalistTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                header
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                BarcodeStripe(color: BrutalistTheme.foreground,
                              seed: UInt64(abs(serial.hashValue)))
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 6)

            CornerRegistrationMarks(color: BrutalistTheme.foreground)
        }
        .foregroundStyle(BrutalistTheme.foreground)
    }

    /// Split "JD 2461158.1699" into ("JD", "2461158.1699") for two-typeface display.
    private var serialPrefix: String {
        guard let i = serial.firstIndex(of: " ") else { return "" }
        return String(serial[..<i])
    }
    private var serialValue: String {
        guard let i = serial.firstIndex(of: " ") else { return serial }
        return String(serial[serial.index(after: i)...])
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.brutalistLabel(20))
                    .foregroundStyle(BrutalistTheme.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                if let subtitle {
                    Text(subtitle.uppercased())
                        .font(.brutalistDecorative(13))
                        .foregroundStyle(BrutalistTheme.muted)
                }
            }
            Spacer()
            // Decorative JD chip — both prefix and value rendered in Bitcount,
            // since the panel header serial is decoration, not a value to read.
            HStack(spacing: 6) {
                Text(serialPrefix)
                    .font(.brutalistDecorative(13))
                    .foregroundStyle(BrutalistTheme.muted)
                Text(serialValue)
                    .font(.brutalistDecorative(15))
                    .foregroundStyle(BrutalistTheme.accent)
            }
            .padding(.top, 4)
        }
    }
}
