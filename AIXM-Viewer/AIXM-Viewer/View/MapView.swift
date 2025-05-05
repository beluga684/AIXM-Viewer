import SwiftUI
import MapKit

/// Представление карты для отображения AIXM-объектов (аэропортов, VOR, взлётных полос).
struct MapView: View {
    // MARK: - Properties
    
    /// Позиция камеры карты, связанная с родительским представлением.
    @Binding var mapCameraPosition: MapCameraPosition
    
    /// Парсер AIXM-данных, предоставляющий объекты для отображения.
    @ObservedObject var parser: AIXMParser
    
    /// Стиль карты (стандартный, спутниковый или гибридный).
    let mapStyle: MapStyleType
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $mapCameraPosition) {
                // Аннотации для точек (аэропорты, VOR, взлётные полосы)
                ForEach(parser.dots) { object in
                    Annotation(
                        object.id.uuidString,
                        coordinate: object.coordinate
                    ) {
                        switch object.type {
                        case .airport:
                            AirportMarker()
                        case .vor:
                            VorMarker()
                        case .runway:
                            RunwayMarker()
                        }
                    }
                }
                
                // Линии для взлётных полос
                ForEach(parser.groupedRunways) { runway in
                    MapPolyline(
                        coordinates: [
                            runway.startPoint.coordinate,
                            runway.endPoint.coordinate
                        ]
                    )
                    .stroke(.purple, lineWidth: 5)
                }
            }
            .mapStyle(mapStyle.mapStyle)
            .ignoresSafeArea()
            .onChange(of: parser.dots) { _, newDots in
                centerMapOnFirstAirport(newDots)
            }
        }
        .frame(maxHeight: .infinity)
        .background(.white)
        .clipShape(.rect(cornerRadius: Constants.mapCornerRadius))
    }
    
    // MARK: - Private Methods
    
    /// Центрирует карту на координатах первого аэропорта из списка.
    /// - Parameter dots: Список объектов карты (`MapItem`).
    private func centerMapOnFirstAirport(_ dots: [MapItem]) {
        guard let firstAirport = dots.first(where: { $0.type == .airport }) else {
            return
        }
        mapCameraPosition = .region(
            MKCoordinateRegion(
                center: firstAirport.coordinate,
                span: Constants.zoomSpan
            )
        )
    }
}

// MARK: - Preview

#Preview {
    MapView(
        mapCameraPosition: .constant(.automatic),
        parser: AIXMParser(),
        mapStyle: .standard
    )
}
