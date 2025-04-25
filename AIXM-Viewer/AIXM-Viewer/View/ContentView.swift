import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var parser = AIXM_Parser()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: parser.dots) { airport in
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
        .onChange(of: parser.dots) { newDots in
            if let firstAirport = newDots.first {
                region = MKCoordinateRegion(
                    center: firstAirport.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
                )
            }
        }
        .edgesIgnoringSafeArea(.all)
        .alert("Уведомление", isPresented: $parser.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(parser.alertMessage)
        }
    }
}

#Preview {
    ContentView()
}
