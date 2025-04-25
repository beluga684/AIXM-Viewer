import SwiftUI
import MapKit

struct AirportHeliport: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: AirportHeliport, rhs: AirportHeliport) -> Bool {
        lhs.id == rhs.id
    }
}
