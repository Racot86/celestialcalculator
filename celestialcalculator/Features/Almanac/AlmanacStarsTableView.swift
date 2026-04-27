import SwiftUI

/// Daily SHA + Dec table for the 57 navigational stars.
struct AlmanacStarsTableView: View {
    let stars: [AlmanacStarRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("STAR").frame(width: 110, alignment: .leading)
                Text("MAG").frame(width: 38, alignment: .trailing)
                Text("SHA").frame(width: 92, alignment: .leading)
                Text("DEC").frame(width: 100, alignment: .leading)
            }
            .font(.brutalistMono(8))
            .foregroundStyle(BrutalistTheme.muted)
            .padding(.vertical, 4)
            Rectangle().fill(BrutalistTheme.foreground.opacity(0.4)).frame(height: 1)

            ForEach(stars) { star in
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(star.name.uppercased()).font(.brutalistLabel(11))
                        Text(star.bayer).font(.brutalistMono(8)).foregroundStyle(BrutalistTheme.muted)
                    }
                    .frame(width: 110, alignment: .leading)
                    Text(String(format: "%.2f", star.magnitude))
                        .font(.brutalistMono(11))
                        .foregroundStyle(BrutalistTheme.muted)
                        .frame(width: 38, alignment: .trailing)
                    Text(AlmanacFormat.gha(star.shaDeg))
                        .font(.brutalistMonoBold(11))
                        .frame(width: 92, alignment: .leading)
                    Text(AlmanacFormat.dec(star.decDeg))
                        .font(.brutalistMonoBold(11))
                        .frame(width: 100, alignment: .leading)
                }
                .foregroundStyle(BrutalistTheme.foreground)
                .padding(.vertical, 3)
                Rectangle().fill(BrutalistTheme.foreground.opacity(0.08)).frame(height: 1)
            }
        }
    }
}
