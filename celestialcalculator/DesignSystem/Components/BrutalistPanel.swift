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
                Spacer(minLength: 0)
                BarcodeStripe(color: BrutalistTheme.foreground,
                              seed: UInt64(abs(serial.hashValue)))
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)

            CornerRegistrationMarks(color: BrutalistTheme.foreground)
        }
        .foregroundStyle(BrutalistTheme.foreground)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.brutalistLabel(20))
                    .foregroundStyle(BrutalistTheme.foreground)
                if let subtitle {
                    Text(subtitle.uppercased())
                        .font(.brutalistMono(11))
                        .foregroundStyle(BrutalistTheme.muted)
                }
            }
            Spacer()
            Text(serial)
                .font(.brutalistMonoBold(11))
                .foregroundStyle(BrutalistTheme.accent)
                .padding(.top, 4)
        }
    }
}
