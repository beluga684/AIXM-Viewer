import MapKit

class AIXM_Parser: NSObject, ObservableObject, XMLParserDelegate {
    @Published var dots: [MapItem] = []
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var currentFileName = "Файл не выбран"
    
    private var currentTag = ""
    private var currentLat: Double?
    private var currentLon: Double?
    
    private var inARP = false
    private var inVORLocation = false
    private var inRunawayLocation = false
    
    private var currentType: MapItemType?
    
    func parse(fileURL: URL) {
        dots.removeAll()
        currentFileName = fileURL.lastPathComponent
        
        guard fileURL.startAccessingSecurityScopedResource() else {
            showError("Ошибка доступа к файлу")
            return
        }
        
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
        
        guard let parser = XMLParser(contentsOf: fileURL) else {
            showError("Не удалось создать парсер для файла")
            return
        }
        
        parser.delegate = self
        if parser.parse() {
            showSuccess()
        } else {
            showError(
                "Ошибка при парсинге XML: \(parser.parserError?.localizedDescription ?? "Неизвестная ошибка")"
            )
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentTag = elementName
        
        if elementName.contains("AirportHeliport") {
            currentType = .airport
        } else if elementName.contains("VOR") {
            currentType = .vor
        } else if elementName.contains("RunwayCentrelinePoint") {
            currentType = .runway
        }
        
        if elementName.contains("ARP") {
            inARP = true
        } else if elementName.contains("location") && currentType == .vor {
            inVORLocation = true
        } else if elementName.contains("location") && currentType == .runway {
            inRunawayLocation = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if (inARP || inVORLocation || inRunawayLocation), currentTag
            .contains("pos") {
            parseCoordinates(from: trimmed)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName.contains("location") && currentType == .runway {
            inRunawayLocation = false
        } else if elementName.contains("ARP") {
            inARP = false
        } else if elementName.contains("location") && currentType == .vor {
            inVORLocation = false
        }
        
        if elementName.contains("RunwayCentrelinePointTimeSlice") ||
            elementName.contains("AirportHeliportTimeSlice") ||
            elementName.contains("VORTimeSlice"){
            addDotIfValid()
        }
    }
    
    private func parseCoordinates(from string: String) {
        let coords = string.split(separator: " ")
        if coords.count == 2,
           let lat = Double(coords[0]),
           let lon = Double(coords[1]) {
            currentLat = lat
            currentLon = lon
        }
    }
    
    private func addDotIfValid() {
        if let lat = currentLat, let lon = currentLon, let type = currentType {
            let item = MapItem(
                coordinate: CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: lon
                ),
                type: type
            )
            dots.append(item)
        }
        currentLat = nil
        currentLon = nil
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func showSuccess() {
        alertMessage = "Все окей"
        showAlert = true
    }

    var groupedRunways: [Runway] {
        let runwayDots = dots.filter { $0.type == .runway }
        var runways: [Runway] = []
        for i in stride(from: 0, to: runwayDots.count, by: 2) {
            guard i + 1 < runwayDots.count else { break }
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
