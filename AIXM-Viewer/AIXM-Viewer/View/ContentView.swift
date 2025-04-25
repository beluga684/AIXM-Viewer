import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var parser = AIXM_Parser()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 14.0, longitude: -87.0),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: parser.airportHeliports) { airport in
            MapAnnotation(coordinate: airport.coordinate) {
                VStack {
                    Image(systemName: "airplane.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            parser.parse()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
