import SwiftUI
import MapKit

class AIXM_Parser: NSObject, ObservableObject, XMLParserDelegate {
    @Published var airportHeliports: [AirportHeliport] = []
    
    private var currentElement = ""
    private var currentLat: Double?
    private var currentLon: Double?
    private var inARP = false

    func parse() {
        guard let url = Bundle.main.url(forResource: "COCESNA_20170516_sample", withExtension: "xml"),
              let parser = XMLParser(contentsOf: url) else {
            print("XML not found")
            return
        }
        parser.delegate = self
        parser.parse()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        if elementName.contains("ARP") {
            inARP = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if inARP && currentElement.contains("pos") {
            let coords = trimmed.split(separator: " ")
            if coords.count == 2, let lat = Double(coords[0]), let lon = Double(coords[1]) {
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
                let airport = AirportHeliport(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                airportHeliports.append(airport)
            }
            currentLat = nil
            currentLon = nil
        }
    }
}
