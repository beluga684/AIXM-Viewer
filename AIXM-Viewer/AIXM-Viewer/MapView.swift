import SwiftUI
import MapLibre

struct MapView: UIViewRepresentable {
    func makeUIView(context _: Context) -> MLNMapView {
        let mapView = MLNMapView()
        return mapView
    }
    
    func updateUIView(_: MLNMapView, context _: Context) {}
}
