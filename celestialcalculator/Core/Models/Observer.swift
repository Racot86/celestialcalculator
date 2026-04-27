import Foundation

struct Observer: Equatable, Hashable {
    var date: Date
    var latitude: Double
    var longitude: Double
    var elevation: Double

    init(date: Date = Date(), latitude: Double = 0, longitude: Double = 0, elevation: Double = 0) {
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
    }
}
