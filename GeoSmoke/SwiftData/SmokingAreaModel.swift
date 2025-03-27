import SwiftData

@Model
class SmokingArea {
    var name: String
    var location: String
    var longitude: Double
    var latitude: Double
    var photoURL: String
    var disposalPhotoURL: String
    var disposalDirection: String
    
    init(name: String, location: String, latitude: Double,longitude: Double,  photoURL: String, disposalPhotoURL: String, disposalDirection: String){
        self.name = name
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.disposalPhotoURL = disposalPhotoURL
        self.disposalDirection = disposalDirection
    }
}
