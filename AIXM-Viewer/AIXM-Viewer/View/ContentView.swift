import SwiftUI
import MapKit
import UniformTypeIdentifiers

// MARK: - константы
private enum Constants {
    static let mapCornerRadius: CGFloat = 20
    static let markerSize: CGFloat = 8
    static let markerStrokeWidth: CGFloat = 1
    static let defaultSpan = MKCoordinateSpan(
        latitudeDelta: 180.0, longitudeDelta: 180.0
    )
    static let zoomSpan = MKCoordinateSpan(
        latitudeDelta: 1.0, longitudeDelta: 1.0
    )
}

// MARK: - маркер аэропорта
private struct AirportMarker: View {
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: Constants.markerSize, height: Constants.markerSize)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: Constants.markerStrokeWidth)
            )
    }
}

// MARK: - кнопка выбора файла
private struct FilePickerButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "doc.fill")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

// MARK: - рабочее окно
struct ContentView: View {
    @StateObject private var parser = AIXM_Parser()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: Constants.defaultSpan
    )
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
    
    private var mapView: some View {
        ZStack(alignment: .top) {
            Map(
                coordinateRegion: $region,
                annotationItems: parser.dots
            ) { airport in
                MapAnnotation(coordinate: airport.coordinate) {
                    AirportMarker()
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onChange(of: parser.dots, initial: false) { _, newDots in
                centerMapOnFirstAirport(newDots)
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(Constants.mapCornerRadius)
    }

    private func centerMapOnFirstAirport(_ airports: [AirportHeliport]) {
        if let firstAirport = airports.first {
            region = MKCoordinateRegion(
                center: firstAirport.coordinate,
                span: Constants.zoomSpan
            )
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
