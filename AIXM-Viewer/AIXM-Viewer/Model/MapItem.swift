import MapKit

/// Тип элемента на карте.
enum MapItemType: CaseIterable {
    case airport
    case vor
    case runway
}

/// Модель элемента на карте, представляющая точку с координатами и типом.
struct MapItem: Identifiable, Equatable {
    /// Уникальный идентификатор элемента.
    let id: UUID = .init()
    
    /// Географические координаты элемента на карте.
    let coordinate: CLLocationCoordinate2D
    
    /// Тип элемента на карте (аэропорт / VOR / ВПП).
    let type: MapItemType
    
    // MARK: - Equatable
    
    /// Сравнивает два объекта `MapItem` на равенство по их идентификатору.
    /// - Parameters:
    ///   - lhs: Первый объект для сравнения.
    ///   - rhs: Второй объект для сравнения.
    /// - Returns: `true`, если идентификаторы совпадают, иначе `false`.
    static func == (lhs: MapItem, rhs: MapItem) -> Bool {
        lhs.id == rhs.id
    }
}
