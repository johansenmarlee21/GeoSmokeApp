import SwiftUI
import SwiftData

struct RootView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var showSplash = true
    let modelContainer: ModelContainer

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity.combined(with: .scale))
            } else {
                ContentView(
                    selectedAmbience: "dark",
                    selectedCrowd: "low",
                    selectedFacilities: [],
                    selectedTypes: []
                )
                .modelContainer(modelContainer)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                locationManager.getUserLocation{location in
                    print("Location recieved in splash: \(String(describing: location))")
                }
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}
