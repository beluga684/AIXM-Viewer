import MapKit
import SwiftUI

/// Тип стиля карты, используемый для отображения различных видов карты.
enum MapStyleType: String, CaseIterable, Identifiable {
    case imagery = "Спутниковая"
    case hybrid = "Гибридная"
    case standard = "Стандартная"
    
    // MARK: - Identifiable
    
    /// Уникальный идентификатор стиля карты, основанный на строковом представлении.
    var id: String {
        rawValue
    }
    
    // MARK: - Map Style
    
    /// Стиль карты, соответствующий текущему типу, для использования с `MapKit`.
    var mapStyle: MapStyle {
        switch self {
        case .standard:
            return .standard
        case .hybrid:
            return .hybrid
        case .imagery:
            return .imagery
        }
    }
}
