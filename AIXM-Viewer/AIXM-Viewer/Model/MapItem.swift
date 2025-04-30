import MapKit

enum MapItemType {
    case airport
    case vor
}

struct MapItem: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let type: MapItemType

    static func == (lhs: MapItem, rhs: MapItem) -> Bool {
        lhs.id == rhs.id
    }
}
