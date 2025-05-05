import SwiftUI

/// Маркер для отображения аэропорта на карте.
struct AirportMarker: View {
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.7))
                .frame(width: Constants.markerSize * 1.4, height: Constants.markerSize * 1.4)
            
            Image(systemName: "airplane.circle.fill")
                .foregroundStyle(.blue)
                .frame(width: Constants.markerSize, height: Constants.markerSize)
        }
        .accessibilityLabel("Аэропорт")
    }
}

/// Маркер для отображения VOR (радионавигационной точки) на карте.
struct VorMarker: View {
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.7))
                .frame(width: Constants.markerSize * 1.4, height: Constants.markerSize * 1.4)
            
            Image(systemName: "wifi.circle.fill")
                .foregroundStyle(.red)
                .frame(width: Constants.markerSize, height: Constants.markerSize)
        }
        .accessibilityLabel("VOR")
    }
}

/// Маркер для отображения точки взлётно-посадочной полосы на карте.
struct RunwayMarker: View {
    // MARK: - Body
    
    var body: some View {
        Circle()
            .fill(.purple)
            .frame(width: Constants.markerSize, height: Constants.markerSize)
            .overlay(
                Circle()
                    .stroke(.white, lineWidth: Constants.markerStrokeWidth)
            )
            .accessibilityLabel("Взлётная полоса")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        AirportMarker()
        VorMarker()
        RunwayMarker()
    }
    .padding()
    .background(.gray.opacity(0.1))
}
