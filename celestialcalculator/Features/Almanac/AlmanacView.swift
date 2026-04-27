import SwiftUI

struct AlmanacView: View {
    @Bindable var viewModel: AlmanacViewModel
    @State private var editingDate = false

    var body: some View {
        BrutalistPanel(serial: serial,
                       title: "Almanac",
                       subtitle: subtitleText) {
            VStack(alignment: .leading, spacing: 12) {
                dayBar
                if let day = viewModel.day, !viewModel.isLoading {
                    dayContent(day)
                } else {
                    loaderArea
                }
            }
        }
        .sheet(isPresented: $editingDate) {
            DateSheet(date: $viewModel.selectedDate)
        }
    }

    private var subtitleText: String {
        if let day = viewModel.day {
            return "\(day.dayOfWeek) • \(day.dateString) UT"
        } else {
            return "GENERATING…"
        }
    }

    private var serial: String {
        let jd = JulianDate.julianDay(from: viewModel.selectedDate)
        return String(format: "JD %.2f", jd)
    }

    @ViewBuilder
    private func dayContent(_ day: AlmanacDay) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sectionTitle("HOURLY EPHEMERIS  (Aries · Sun · Planets · Moon)")
                AlmanacHourlyTableView(hours: day.hours)

                sectionTitle("STARS  (SHA & Dec at 12h UT)")
                AlmanacStarsTableView(stars: day.stars)

                sectionTitle("TWILIGHT & RISE/SET — UT, by latitude (Greenwich meridian)")
                AlmanacTwilightTableView(rows: day.twilight)

                AlmanacEventsView(phenomena: day.phenomena)
            }
            .padding(.bottom, 12)
        }
    }

    private var loaderArea: some View {
        VStack {
            Spacer()
            BrutalistLoader(label: "COMPUTING ALMANAC")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var dayBar: some View {
        HStack(spacing: 6) {
            stepButton(label: "‹‹", days: -7)
            stepButton(label: "‹",  days: -1)
            Button { editingDate = true } label: {
                Text(dateText)
                    .font(.brutalistMonoBold(14))
                    .foregroundStyle(BrutalistTheme.foreground)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .overlay(Rectangle().stroke(BrutalistTheme.foreground.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
            stepButton(label: "›",  days:  1)
            stepButton(label: "››", days:  7)
            Button { viewModel.jumpToToday() } label: {
                Text("TODAY")
                    .font(.brutalistTextBold(10))
                    .padding(.horizontal, 8).padding(.vertical, 6)
                    .background(BrutalistTheme.accent)
                    .foregroundStyle(BrutalistTheme.background)
            }
            .buttonStyle(.plain)
        }
    }

    private var dateText: String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC"); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: viewModel.selectedDate)
    }

    private func stepButton(label: String, days: Int) -> some View {
        Button { viewModel.step(days: days) } label: {
            Text(label)
                .font(.brutalistMonoBold(13))
                .foregroundStyle(BrutalistTheme.accent)
                .frame(width: 28, height: 28)
                .background(BrutalistTheme.background)
                .overlay(Rectangle().stroke(BrutalistTheme.accent, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func sectionTitle(_ s: String) -> some View {
        Text(s)
            .font(.brutalistTextBold(10))
            .foregroundStyle(BrutalistTheme.accent)
    }
}
