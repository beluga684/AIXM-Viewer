import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MapView().edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    ContentView()
}
