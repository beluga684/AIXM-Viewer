import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var parser = AIXM_Parser()
    @State private var map_region: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: Constants.defaultSpan
    ))
    @State private var showingFilePicker = false

    var body: some View {
        VStack(spacing: 10) {
            mapView
            
            HStack {
                Text(parser.currentFileName)
                    .font(.headline)
                
                Spacer()
                
                FilePickerButton(action: { showingFilePicker = true })
            }
            .padding()
        }
        .padding()
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.xml],
            allowsMultipleSelection: false
        ) { result in
            handleFilePickerResult(result)
        }
        .alert("Уведомление", isPresented: $parser.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(parser.alertMessage)
        }
    }

    private var mapContent: some View {
        Map(position: $map_region) {
            ForEach(parser.dots) { object in
                Annotation(
                    object.id.uuidString,
                    coordinate: object.coordinate
                ) {
                    if object.type == .airport {
                        AirportMarker()
                    } else if object.type == .vor {
                        VorMarker()
                    } else {
                        RunwayMarker()
                    }
                }
            }
        }
        .mapStyle(.imagery)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: parser.dots) { oldValue, newValue in
            centerMapOnFirstAirport(newValue)
        }
    }

    private var mapView: some View {
        ZStack(alignment: .top) {
            mapContent
        }
        .frame(maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(Constants.mapCornerRadius)
    }
    
    private func centerMapOnFirstAirport(_ airports: [MapItem]) {
        if let firstAirport = airports.first {
            map_region = .region(MKCoordinateRegion(
                center: firstAirport.coordinate,
                span: Constants.zoomSpan
            ))
        }
    }
    
    private func handleFilePickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let files):
            guard let file = files.first else { return }
            parser.parse(fileURL: file)
        case .failure(let error):
            parser.alertMessage = "Ошибка при выборе файла: \(error.localizedDescription)"
            parser.showAlert = true
        }
    }
}

#Preview {
    ContentView()
}
