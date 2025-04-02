import SwiftUI
import SwiftData

@main
struct GeoSmokeApp: App {
    
    var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema([SmokingArea.self, Facility.self, LocationAllPhoto.self])
            let config = ModelConfiguration()
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("❌ Failed to load model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onAppear {
                    preloadDataIfNeeded()
                }
                .preferredColorScheme(.light)
        }
    }

    private func preloadDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        let hasPreloaded = UserDefaults.standard.bool(forKey: "hasPreloadedSmokingArea")

        guard !hasPreloaded else {
            print("ℹ️ Preload skipped: already done.")
            return
        }
        
        SmokingAreaSeeder.seedDataIfNeeded(context: context)
        UserDefaults.standard.set(true, forKey: "hasPreloadedSmokingArea")
        print("✅ Preload completed on first launch.")
    }
}

//struct GeoSmokeApp: App {
//    
//    var sharedModelContainer: ModelContainer = {
//        do {
//            let schema = Schema([SmokingArea.self, Facility.self])
//            let config = ModelConfiguration()
//            return try ModelContainer(for: schema, configurations: [config])
//        } catch {
//            fatalError("❌ Failed to load model container: \(error)")
//        }
//    }()
//
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .modelContainer(sharedModelContainer)
//                .onAppear {
//                    resetAndReseedData()
//                }
//        }
//    }
//    
//    private func resetAndReseedData() {
//        let context = sharedModelContainer.mainContext
//        
//        do {
//            try context.delete(model: SmokingArea.self)
//            
//            SmokingAreaSeeder.seedData(context: context)
//            
//            print("✅ Data reset and reseeded successfully!")
//        } catch {
//            print("❌ Error resetting data: \(error)")
//        }
//    }
//}
