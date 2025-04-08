import SwiftUI
import SwiftData

struct RootView: View {
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
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}
