//
//  SmokingAreaModel.swift
//  GeoSmoke
//
//  Created by Ageng Tawang Aryonindito on 06/04/25.
//

import SwiftData

@Model
class SmokingArea: Identifiable {
    var name: String
    var location: String
    var longitude: Double
    var latitude: Double
    var photoURL: String
    var disposalPhotoURL: String
    var disposalDirection: String
    @Relationship(deleteRule: .cascade) var facilities: [Facility] = []
    var isFavorite: Bool
    @Relationship(deleteRule: .cascade) var allPhoto: [LocationAllPhoto] = []
    var facilityGrade: String
    
    init(name: String, location: String, latitude: Double,longitude: Double,  photoURL: String, disposalPhotoURL: String, disposalDirection: String, facilities: [Facility] = [], isFavorite: Bool = false, allPhoto: [LocationAllPhoto] = [], facilityGrade: String){
        self.name = name
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.disposalPhotoURL = disposalPhotoURL
        self.disposalDirection = disposalDirection
        self.facilities = facilities
        self.isFavorite = isFavorite
        self.allPhoto = allPhoto
        self.facilityGrade = facilityGrade
    }
}

@Model
class Facility {
    var name: String

    init(name: String) {
        self.name = name
    }
}

@Model
class LocationAllPhoto {
    var photo: String

    init(photo: String) {
        self.photo = photo
    }
}
