import Foundation
import Observation

@Observable
@MainActor
final class AlmanacViewModel {
    /// Pure ephemeris page — only input is the UT date.
    var selectedDate: Date {
        didSet { recompute() }
    }
    private(set) var day: AlmanacDay?
    private(set) var isLoading: Bool = false

    @ObservationIgnored
    private var task: Task<Void, Never>?

    init(selectedDate: Date = Date()) {
        self.selectedDate = selectedDate
        recompute()
    }

    func step(days: Int) {
        selectedDate = selectedDate.addingTimeInterval(Double(days) * 86400.0)
    }

    func jumpToToday() {
        selectedDate = Date()
    }

    private func recompute() {
        task?.cancel()
        isLoading = true
        let date = selectedDate
        task = Task { [weak self] in
            let result = await Task.detached(priority: .userInitiated) {
                AlmanacGenerator.generate(for: date)
            }.value
            await MainActor.run {
                guard let self else { return }
                if Task.isCancelled { return }
                self.day = result
                self.isLoading = false
            }
        }
    }

    deinit { task?.cancel() }
}
