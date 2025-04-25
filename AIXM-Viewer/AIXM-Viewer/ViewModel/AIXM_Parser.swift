import SwiftUI
import MapKit

class AIXM_Parser: NSObject, ObservableObject, XMLParserDelegate {
    @Published var dots: [AirportHeliport] = []
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private var currentTag = ""
    private var currentLat: Double?
    private var currentLon: Double?
    private var inARP = false

    func parse() {
        guard let url = Bundle.main.url(
            forResource: "Donlon",
            withExtension: "xml"
        ),
              let parser = XMLParser(contentsOf: url) else {
            alertMessage = "Ошибка: XML файл не найден"
            showAlert = true
            return
        }
        parser.delegate = self
        if parser.parse() {
            alertMessage = "Все окей"
        } else {
            alertMessage = "Ошибка при парсинге XML: \(parser.parserError?.localizedDescription ?? "Неизвестная ошибка")"
        }
        showAlert = true
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
            let coords = trimmed.split(separator: " ")
            if coords.count == 2, let lat = Double(coords[0]), let lon = Double(
                coords[1]
            ) {
                currentLat = lat
                currentLon = lon
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName.contains("ARP") {
            inARP = false
        }
        if elementName.contains("AirportHeliportTimeSlice") {
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
    }
}
