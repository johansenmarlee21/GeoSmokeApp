import SwiftUI
import SwiftData

@main
struct GeoSmokeApp: App {
    
    var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema([SmokingArea.self, Facility.self, LocationAllPhoto.self, UserModel.self])
            let config = ModelConfiguration()
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("❌ Failed to load model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(modelContainer: sharedModelContainer)
                .onAppear {
                    preloadDataIfNeeded()
                }
                .preferredColorScheme(.light)
        }

//        WindowGroup {
//            ContentView(
//                selectedAmbience: "dark",
//                selectedCrowd: "low",
//                selectedFacilities: [],
//                selectedTypes: []
//            )
//            .modelContainer(sharedModelContainer)
//            .onAppear {
//                resetAndReseedData()
//            }
//        }
    }

    private func preloadDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        let hasPreloaded = UserDefaults.standard.bool(forKey: "hasPreloadedSmokingArea")

        guard !hasPreloaded else {
            print("ℹ️ Preload skipped: already done.")
            return
        }
        
        SmokingAreaSeeder.seedDataIfNeeded(context: context)
        let testUser = UserModel(
            ambiencePreference: "Bright",
            crowdLevelPreference: "Low",
            facilityPreference: ["Chair", "Waste Bin"],
            type: ["Cigarette"]
        )
        context.insert(testUser)
        UserDefaults.standard.set(true, forKey: "hasPreloadedSmokingArea")
        print("✅ Preload completed on first launch.")
    }

}
//=======
//    
//    private func resetAndReseedData() {
//        let context = sharedModelContainer.mainContext
//
//        do {
//            try context.delete(model: SmokingArea.self)
//            try context.delete(model: UserModel.self)
//
//            SmokingAreaSeeder.seedData(context: context)
//
//            // ✅ Insert dummy user
//            let testUser = UserModel(
//                ambiencePreference: "Bright",
//                crowdLevelPreference: "Low",
//                facilityPreference: ["Chair", "Waste Bin"],
//                type: ["Cigarette"]
//            )
//            context.insert(testUser)
//
//            try context.save()
//            print("✅ Data reset, reseeded, and inserted test user")
//        } catch {
//            print("❌ Error resetting data: \(error)")
//>>>>>>> 00a4608fbf7cac8e83d903cc65a2962d30aa33cd
//        

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
