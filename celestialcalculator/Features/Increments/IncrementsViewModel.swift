import Foundation
import Observation

@Observable
final class IncrementsViewModel {
    /// Currently displayed minute of the hour (0…59).
    var selectedMinute: Int = 0

    /// All 61 rows for the current minute: SS, Sun/Planets, Aries.
    var incrementRows: [IncrementRow] {
        (0...60).map { s in
            let sun = IncrementsCalculator.formatDM(
                arcmin: IncrementsCalculator.sunPlanetsArcmin(min: selectedMinute, sec: s))
            let aries = IncrementsCalculator.formatDM(
                arcmin: IncrementsCalculator.ariesArcmin(min: selectedMinute, sec: s))
            return IncrementRow(seconds: s,
                                sunDeg: sun.deg, sunArcmin: sun.arcminInDeg,
                                ariesDeg: aries.deg, ariesArcmin: aries.arcminInDeg)
        }
    }

    /// v/d correction rows for the current minute.
    /// Range chosen to cover normal almanac values (Moon v up to ~17′/h).
    var correctionRows: [CorrectionRow] {
        let values = stride(from: 0.0, through: 20.0, by: 0.1).map { round($0 * 10) / 10 }
        return values.map { v in
            let raw = IncrementsCalculator.vdCorrectionArcmin(v: v, min: selectedMinute)
            return CorrectionRow(v: v,
                                 correction: IncrementsCalculator.roundToTenth(raw))
        }
    }

    func step(_ delta: Int) {
        var next = selectedMinute + delta
        if next < 0 { next = 0 }
        if next > 59 { next = 59 }
        selectedMinute = next
    }
}

struct IncrementRow: Identifiable {
    let seconds: Int
    let sunDeg: Int
    let sunArcmin: Double
    let ariesDeg: Int
    let ariesArcmin: Double
    var id: Int { seconds }
}

struct CorrectionRow: Identifiable {
    let v: Double
    let correction: Double
    var id: Double { (v * 10).rounded() }
}
