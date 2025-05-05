import MapKit
import Foundation

/// Парсер для обработки AIXM XML-файлов, извлекающий точки (аэропорты, VOR, взлётные полосы).
final class AIXMParser: NSObject, ObservableObject, XMLParserDelegate {
    // MARK: - Published Properties
    
    /// Список точек, извлечённых из XML (аэропорты, VOR, взлётные полосы).
    @Published var dots: [MapItem] = []
    
    /// Флаг для отображения алерта с сообщением об ошибке или успехе.
    @Published var showAlert = false
    
    /// Сообщение для алерта, описывающее результат парсинга.
    @Published var alertMessage = ""
    
    /// Имя текущего файла, отображаемое в UI.
    @Published var currentFileName = NSLocalizedString("Файл не выбран", comment: "Default file name")
    
    // MARK: - Private Properties
    
    private var currentTag = ""
    private var currentLat: Double?
    private var currentLon: Double?
    private var currentType: MapItemType?
    
    private var isInARP = false
    private var isInVORLocation = false
    private var isInRunwayLocation = false
    
    // MARK: - Public Methods
    
    /// Парсит AIXM XML-файл по указанному URL.
    /// - Parameter fileURL: URL файла для парсинга.
    func parse(fileURL: URL) {
        dots.removeAll()
        currentFileName = fileURL.lastPathComponent
        
        guard fileURL.startAccessingSecurityScopedResource() else {
            showError(NSLocalizedString("FileAccessError", comment: "File access error"))
            return
        }
        defer { fileURL.stopAccessingSecurityScopedResource() }
        
        guard let parser = XMLParser(contentsOf: fileURL) else {
            showError(NSLocalizedString("ParserCreationError", comment: "Parser creation error"))
            return
        }
        
        parser.delegate = self
        if parser.parse() {
            showSuccess()
        } else {
            let errorMessage = parser.parserError?.localizedDescription ?? NSLocalizedString("UnknownError", comment: "Unknown error")
            showError(NSLocalizedString("ParsingError", comment: "Parsing error") + ": \(errorMessage)")
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes: [String: String]
    ) {
        currentTag = elementName
        
        switch elementName {
        case _ where elementName.contains("AirportHeliport"):
            currentType = .airport
        case _ where elementName.contains("VOR"):
            currentType = .vor
        case _ where elementName.contains("RunwayCentrelinePoint"):
            currentType = .runway
        default:
            break
        }
        
        switch elementName {
        case _ where elementName.contains("ARP"):
            isInARP = true
        case _ where elementName.contains("location") && currentType == .vor:
            isInVORLocation = true
        case _ where elementName.contains("location") && currentType == .runway:
            isInRunwayLocation = true
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, (isInARP || isInVORLocation || isInRunwayLocation), currentTag.contains("pos") else {
            return
        }
        
        parseCoordinates(from: trimmed)
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        switch elementName {
        case _ where elementName.contains("location") && currentType == .runway:
            isInRunwayLocation = false
        case _ where elementName.contains("ARP"):
            isInARP = false
        case _ where elementName.contains("location") && currentType == .vor:
            isInVORLocation = false
        case _ where elementName.contains("RunwayCentrelinePointTimeSlice"),
             _ where elementName.contains("AirportHeliportTimeSlice"),
             _ where elementName.contains("VORTimeSlice"):
            addDotIfValid()
        default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    /// Парсит координаты из строки в формате "lat lon".
    /// - Parameter string: Строка с координатами.
    private func parseCoordinates(from string: String) {
        let coords = string.split(separator: " ").map { String($0) }
        guard coords.count == 2,
              let lat = Double(coords[0]),
              let lon = Double(coords[1]) else {
            return
        }
        currentLat = lat
        currentLon = lon
    }
    
    /// Добавляет точку в `dots`, если координаты и тип валидны.
    private func addDotIfValid() {
        guard let lat = currentLat, let lon = currentLon, let type = currentType else {
            return
        }
        
        let item = MapItem(
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            type: type
        )
        dots.append(item)
        #if DEBUG
        print("Parsed item: \(item.type)")
        #endif
        currentLat = nil
        currentLon = nil
    }
    
    /// Показывает ошибку с указанным сообщением.
    /// - Parameter message: Сообщение об ошибке.
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    /// Показывает сообщение об успешном парсинге.
    private func showSuccess() {
        alertMessage = String(
            format: NSLocalizedString("Отображено \(dots.count) объектов", comment: "Parsed points message")
        )
        showAlert = true
    }
    
    // MARK: - Computed Properties
    
    /// Группирует точки типа `runway` в пары для формирования взлётных полос.
    var groupedRunways: [Runway] {
        let runwayDots = dots.filter { $0.type == .runway }
        var runways: [Runway] = []
        
        for i in stride(from: 0, to: runwayDots.count - 1, by: 2) {
            let runway = Runway(
                id: UUID().uuidString,
                startPoint: runwayDots[i],
                endPoint: runwayDots[i + 1]
            )
            runways.append(runway)
        }
        
        return runways
    }
}
