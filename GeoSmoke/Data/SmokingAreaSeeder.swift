import SwiftData

struct SmokingAreaSeeder {
    static func seedData(context: ModelContext) {
        do {
            let fetchRequest = FetchDescriptor<SmokingArea>()
            let existingAreas = try context.fetch(fetchRequest)
            for area in existingAreas {
                context.delete(area)
            }
            
            let sampleAreas = [
                SmokingArea(
                    name: "The Shady",
                    location: "GOP 1",
                    latitude: -6.3009886,
                    longitude: 106.6510372,
                    photoURL: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
                    disposalPhotoURL: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
                    disposalDirection: "disitu",
                    facilities: [
                        Facility(name: "Chair"),
                        Facility(name: "Waste Bin"),
                        Facility(name: "Roof")
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
                        LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
                        LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
                        LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png")
                    ],
                    facilityGrade: "Moderate",
                    ambience: "Dark",
                    crowdLevel: "Low",
                    smokingTypes: ["Cigarette"]
                ),
                SmokingArea(
                    name: "Garden Seating",
                    location: "Garden",
                    latitude: -6.3013122,
                    longitude: 106.6522975,
                    photoURL: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
                    disposalPhotoURL: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
                    disposalDirection: "disitu",
                    facilities: [
                        Facility(name: "Chair"),
                        Facility(name: "Waste Bin"),
                    ],
                    isFavorite: false,
                    allPhoto: [
                        LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
                        LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
                        LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
                        LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png")
                    ],
                    facilityGrade: "High",
                    ambience: "Dark",
                    crowdLevel: "Low",
                    smokingTypes: ["Cigarette"]
                )
            ]

            for area in sampleAreas {
                context.insert(area)
            }

            try context.save()

        } catch {
            print("Error resetting and seeding data: \(error)")
        }
    }
}
