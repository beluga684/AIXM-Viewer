import SwiftUI
import MapKit

class AIXM_Parser: NSObject, ObservableObject, XMLParserDelegate {
    @Published var dots: [AirportHeliport] = []
//    @Published var showAlert = false
//    @Published var alertMessage = ""
    @Published var currentFileName = "Файл не выбран"
    
    private var currentTag = ""
    private var currentLat: Double?
    private var currentLon: Double?
    private var inARP = false
    
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
            showError("Ошибка при парсинге XML: \(parser.parserError?.localizedDescription ?? "Неизвестная ошибка")")
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentTag = elementName
        if elementName.contains("ARP") {
            inARP = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if inARP && currentTag.contains("pos") {
            parseCoordinates(from: trimmed)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName.contains("ARP") {
            inARP = false
        }
        if elementName.contains("AirportHeliportTimeSlice") {
            addAirportIfValid()
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
    
    private func addAirportIfValid() {
        if let lat = currentLat, let lon = currentLon {
            let airport = AirportHeliport(
                coordinate: CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: lon
                )
            )
            dots.append(airport)
        }
        currentLat = nil
        currentLon = nil
    }
    
    private func showError(_ message: String) {
//        alertMessage = message
//        showAlert = true
    }
    
    private func showSuccess() {
//        alertMessage = "Все окей"
//        showAlert = true
    }
}
