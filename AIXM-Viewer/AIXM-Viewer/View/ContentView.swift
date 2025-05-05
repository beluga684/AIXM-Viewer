import SwiftUI
import MapKit

/// Главное представление приложения для просмотра AIXM-данных на карте.
struct ContentView: View {
    // MARK: - State Properties
    
    @StateObject private var parser = AIXMParser()
    @State private var mapCameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: Constants.defaultSpan
        )
    )
    @State private var isShowingFilePicker = false
    @State private var selectedMapStyle: MapStyleType = .imagery
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 10) {
            Text("AIXM Viewer")
                .font(.headline)
            
            MapView(
                mapCameraPosition: $mapCameraPosition,
                parser: parser,
                mapStyle: selectedMapStyle
            )
            
            Picker("Стиль карты", selection: $selectedMapStyle) {
                ForEach(MapStyleType.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Text(parser.currentFileName)
                    .font(.headline)
                
                Spacer()
                
                FilePickerButton(action: { isShowingFilePicker = true })
            }
        }
        .padding()
        .fileImporter(
            isPresented: $isShowingFilePicker,
            allowedContentTypes: [.xml],
            allowsMultipleSelection: false,
            onCompletion: handleFilePickerResult
        )
        .alert(
            "Уведомление",
            isPresented: $parser.showAlert,
            actions: {
                Button("OK", role: .cancel) { }
            },
            message: {
                Text(parser.alertMessage)
            }
        )
    }
    
    // MARK: - Private Methods
    
    /// Обрабатывает результат выбора файла из файлового пикера.
    /// - Parameter result: Результат выбора файла (успех или ошибка).
    private func handleFilePickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let files):
            guard let fileURL = files.first else { return }
            parser.parse(fileURL: fileURL)
        case .failure(let error):
            parser.alertMessage = "Ошибка при выборе файла: \(error.localizedDescription)"
            parser.showAlert = true
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
