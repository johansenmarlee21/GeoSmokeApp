import SwiftUI
import SwiftData

@main
struct GeoSmokeApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([SmokingArea.self])
        let container = try! ModelContainer(for: schema)
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onAppear {
                    resetAndReseedData()
                }
        }
    }
    
    private func resetAndReseedData() {
        let context = sharedModelContainer.mainContext
        
        do {
            try context.delete(model: SmokingArea.self)
            
            SmokingAreaSeeder.seedData(context: context)
            
            print("✅ Data reset and reseeded successfully!")
        } catch {
            print("❌ Error resetting data: \(error)")
        }
    }
}
