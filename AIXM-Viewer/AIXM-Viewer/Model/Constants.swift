import Foundation
import MapKit

struct Constants {
    static let mapCornerRadius: CGFloat = 20
    static let markerSize: CGFloat = 8
    static let markerStrokeWidth: CGFloat = 1
    static let defaultSpan = MKCoordinateSpan(
        latitudeDelta: 180.0, longitudeDelta: 180.0
    )
    static let zoomSpan = MKCoordinateSpan(
        latitudeDelta: 1.0, longitudeDelta: 1.0
    )
}
