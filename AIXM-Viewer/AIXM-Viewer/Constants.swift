import Foundation
import MapKit

/// Константы, используемые в приложении AIXM Viewer для настройки UI и карты.
enum Constants {
    // MARK: - Map Constants
    
    /// Радиус углов карты.
    static let mapCornerRadius: CGFloat = 8
    
    /// Размер региона карты по умолчанию (глобальный охват).
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 180.0, longitudeDelta: 180.0)
    
    /// Размер региона карты при фокусировке на объекте (например, аэропорте).
    static let zoomSpan = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    
    // MARK: - Marker Constants
    
    /// Размер маркеров на карте (аэропорты, VOR, взлётные полосы).
    static let markerSize: CGFloat = 8
    
    /// Толщина обводки маркеров.
    static let markerStrokeWidth: CGFloat = 1
}
