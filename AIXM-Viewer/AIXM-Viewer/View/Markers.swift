import SwiftUI

struct AirportMarker: View {
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

struct VorMarker: View {
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: Constants.markerSize, height: Constants.markerSize)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: Constants.markerStrokeWidth)
            )
    }
}
