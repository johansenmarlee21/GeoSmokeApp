import SwiftData
import Foundation

struct SmokingAreaSeeder {
    static let preloadKey = "hasPreloadedSmokingArea"
    
    static func seedDataIfNeeded(context: ModelContext) {
        let hasPreloaded = UserDefaults.standard.bool(forKey: preloadKey)
        guard !hasPreloaded else { return }
        
        do {
            let sampleAreas = [
                SmokingArea(
                    name: "The Shady",
                    location: "GOP 1",
                    latitude: -6.3009886,
                    longitude: 106.6510372,
                    photoURL: "TheShady1",
                    disposalPhotoURL: "TheShadyWaste",
                    disposalDirection: "Find the closest zebra crossing, cross it, and then turn left. The garbage can should be on your right side.",
                    facilities: [
                        Facility(name: "Waste Bin"),
                        Facility(name: "Roof")
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "TheShady1"),
                        LocationAllPhoto(photo: "TheShady2"),
                    ],
                    facilityGrade: "Moderate",
                    ambience: "Dark",
                    crowdLevel: "Low",
                    smokingTypes: ["Cigarette", "E-cigarette"]
                ),
                SmokingArea(
                    name: "Garden Seating",
                    location: "Garden",
                    latitude: -6.3013122,
                    longitude: 106.6522975,
                    photoURL: "GardenSeating1",
                    disposalPhotoURL: "GardenSeating2",
                    disposalDirection: "The disposal unit should be located directly at the location.",
                    facilities: [
                        Facility(name: "Chair"),
                        Facility(name: "Waste Bin"),
                        Facility(name: "Roof")
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "GardenSeating1"),
                        LocationAllPhoto(photo: "GardenSeating2"),
                    ],
                    facilityGrade: "High",
                    ambience: "Dark",
                    crowdLevel: "High",
                    smokingTypes: ["Cigarette", "E-cigarette"]
                ),
                SmokingArea(
                    name: "Ecopuff Corner",
                    location: "GOP 6",
                    latitude: -6.303563,
                    longitude: 106.654619,
                    photoURL: "EcopuffCorner1",
                    disposalPhotoURL: "EcopuffCorner2",
                    disposalDirection: "Find the stairs located near you, find for the nearest disposal unit that located near the lobby.",
                    facilities: [
                        Facility(name: "Waste Bin"),
                        Facility(name: "Roof")
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "EcopuffCorner1"),
                        LocationAllPhoto(photo: "EcopuffCorner2"),
                    ],
                    facilityGrade: "Moderate",
                    ambience: "Bright",
                    crowdLevel: "High",
                    smokingTypes: ["E-cigarette"]
                ),
                SmokingArea(
                    name: "The Jog",
                    location: "GOP 1",
                    latitude: -6.30362,
                    longitude: 106.654589,
                    photoURL: "TheJog1",
                    disposalPhotoURL: "TheJog2",
                    disposalDirection: "The disposal unit should be located directly at the location.",
                    facilities: [
                        Facility(name: "Waste Bin"),
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "TheJog1"),
                        LocationAllPhoto(photo: "TheJog2"),
                    ],
                    facilityGrade: "Low",
                    ambience: "Bright",
                    crowdLevel: "Low",
                    smokingTypes: ["E-cigarette", "Cigarette"]
                ),
                SmokingArea(
                    name: "The Smokescape",
                    location: "Garden",
                    latitude: -6.302086,
                    longitude: 106.650891,
                    photoURL: "SmokeScape1",
                    disposalPhotoURL: "SmokeScape2",
                    disposalDirection: "Go to the garden area, find the disposal unit that located inside the garden.",
                    facilities: [
                        Facility(name: "Roof")
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "SmokeScape1"),
                        LocationAllPhoto(photo: "SmokeScape2"),
                    ],
                    facilityGrade: "Low",
                    ambience: "Bright",
                    crowdLevel: "Low",
                    smokingTypes: ["E-cigarette"]
                ),
                SmokingArea(
                    name: "NineLoner",
                    location: "GOP 9",
                    latitude: -6.3023203,
                    longitude: 106.6527786,
                    photoURL: "NineLoner1",
                    disposalPhotoURL: "NineLoner1",
                    disposalDirection: "The disposal unit should be located directly at the location.",
                    facilities: [
                        Facility(name: "Waste Bin"),
                        Facility(name: "Chair"),
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "NineLoner1"),
                        LocationAllPhoto(photo: "NineLoner2"),
                    ],
                    facilityGrade: "Moderate",
                    ambience: "Bright",
                    crowdLevel: "Low",
                    smokingTypes: ["E-cigarette", "Cigarette"]
                ),
                SmokingArea(
                    name: "The SmokeStage",
                    location: "Garden",
                    latitude: -6.3011829,
                    longitude: 106.6529061,
                    photoURL: "SmokeStage1",
                    disposalPhotoURL: "SmokeStage2",
                    disposalDirection: "The disposal unit should be located directly at the location.",
                    facilities: [
                        Facility(name: "Waste Bin"),
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "SmokeStage1"),
                        LocationAllPhoto(photo: "SmokeStage2"),
                    ],
                    facilityGrade: "Low",
                    ambience: "Bright",
                    crowdLevel: "Low",
                    smokingTypes: ["E-cigarette", "Cigarette"]
                ),
                SmokingArea(
                    name: "SixJog",
                    location: "GOP 6",
                    latitude: -6.3028502,
                    longitude: 106.6525899,
                    photoURL: "SixJog1",
                    disposalPhotoURL: "SixJogWaste",
                    disposalDirection: "The disposal unit should be located directly at the location.",
                    facilities: [
                        Facility(name: "Waste Bin"),
                        Facility(name: "Chair")
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "SixJog1"),
                        LocationAllPhoto(photo: "SixJog2"),
                    ],
                    facilityGrade: "Moderate",
                    ambience: "Bright",
                    crowdLevel: "Low",
                    smokingTypes: ["E-cigarette", "Cigarette"]
                ),
                
            ]
            
            for area in sampleAreas {
                context.insert(area)
            }
            
            try context.save()
            UserDefaults.standard.set(true, forKey: preloadKey)
            print("✅ Seeded initial SmokingArea data.")
        } catch {
            print("❌ Error seeding data: \(error)")
        }
    }
}
