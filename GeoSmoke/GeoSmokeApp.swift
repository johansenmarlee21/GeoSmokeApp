import SwiftUI
import SwiftData

@main
struct GeoSmokeApp: App {
    
    var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema([SmokingArea.self, Facility.self, UserModel.self])
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
                    resetAndReseedData()
                }
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
    
    private func resetAndReseedData() {
        let context = sharedModelContainer.mainContext

        do {
            try context.delete(model: SmokingArea.self)
            try context.delete(model: UserModel.self)

            SmokingAreaSeeder.seedData(context: context)

            // ✅ Insert dummy user
            let testUser = UserModel(
                ambiencePreference: "Bright",
                crowdLevelPreference: "Low",
                facilityPreference: ["Chair", "Waste Bin"],
                type: ["Cigarette"]
            )
            context.insert(testUser)

            try context.save()
            print("✅ Data reset, reseeded, and inserted test user")
        } catch {
            print("❌ Error resetting data: \(error)")
        }
    }

}
