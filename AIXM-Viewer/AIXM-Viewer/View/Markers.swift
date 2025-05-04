import SwiftUI

struct AirportMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: Constants.markerSize * 1.4, height: Constants.markerSize * 1.4)
            
            Image(systemName: "airplane.circle.fill")
                .foregroundColor(.blue)
                .frame(width: Constants.markerSize, height: Constants.markerSize)
        }
    }
}

struct VorMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: Constants.markerSize * 1.4, height: Constants.markerSize * 1.4)
            
            Image(systemName: "wifi.circle.fill")
                .foregroundColor(.red)
                .frame(width: Constants.markerSize, height: Constants.markerSize)
        }
    }
}

struct RunwayMarker: View {
    var body: some View {
        Circle()
            .fill(Color.purple)
            .frame(width: Constants.markerSize, height: Constants.markerSize)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: Constants.markerStrokeWidth)
            )
    }
}
