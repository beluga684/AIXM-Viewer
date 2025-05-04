import SwiftUI

struct AirportMarker: View {
    var body: some View {
        Image(systemName: "airplane.circle.fill")
            .foregroundColor(.blue)
            .frame(width: Constants.markerSize, height: Constants.markerSize)
    }
}

struct VorMarker: View {
    var body: some View {
        Image(systemName: "dot.radiowaves.left.and.right")
            .foregroundColor(.red)
            .frame(width: Constants.markerSize, height: Constants.markerSize)
        
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
