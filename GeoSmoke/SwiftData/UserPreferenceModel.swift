import SwiftData
import Foundation

@Model
class UserModel {
    @Attribute(.unique) var id: UUID
    var ambiencePreference: String
    var crowdLevelPreference: String
    var facilityPreference: [String]
    var type: [String]

    init(ambiencePreference: String, crowdLevelPreference: String, facilityPreference: [String], type: [String]) {
        self.id = UUID()
        self.ambiencePreference = ambiencePreference
        self.crowdLevelPreference = crowdLevelPreference
        self.facilityPreference = facilityPreference
        self.type = type
    }
}

@Model
class FacilityPreference: Identifiable {
    var facility: String

    init(facility: String) {
        self.facility = facility
    }
}

@Model
class UserTypeModel: Identifiable {
    var type: String

    init(type: String) {
        self.type = type
    }
}
