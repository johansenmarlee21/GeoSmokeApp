//
//  DetailView.swift
//  GeoSmoke
//
//  Created by Ageng Tawang Aryonindito on 27/03/25.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    var area: SmokingArea
    @Environment(\.modelContext) private var context
    @Query private var users: [UserModel]
    @State private var currentUser: UserModel?
    
    
    
    var body: some View {
        NavigationStack {
            
            HeaderView(area: area).padding(.top, -50)
            ScrollView {
                VStack {
                    LocationInfoView(name: area.name, location: area.location)
                    CarouselView(images: area.allPhoto.map { $0.photo })
                    CigaretteTypeView(types: area.smokingTypes)
                    FacilitiesView(facilities: area.facilities)
                    
                    if let currentUser {
                        PreferenceGaugeView(area: area, userModel: currentUser)
                    }
                    WasteBinDirectionView(photoURL: area.disposalPhotoURL, directions: area.disposalDirection)
                }
                .padding(.top, -5)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                Task {
                    do {
                        let descriptor = FetchDescriptor<UserModel>()
                        let users = try context.fetch(descriptor)
                        
                        if let user = users.first {
                            currentUser = user
                        } else {
                            let testUser = UserModel(
                                ambiencePreference: "Dark",
                                crowdLevelPreference: "Low",
                                facilityPreference: ["Chair", "Waste Bin", "Roof"],
                                type: ["Cigarette", "E-cigarette"]
                            )
                            context.insert(testUser)
                            try context.save()
                            currentUser = testUser
                            print("✅ Inserted test user")
                        }
                    } catch {
                        print("❌ Error fetching/inserting user: \(error)")
                    }
                }
            }
            
        }
    }
}

// MARK: - Header (Back & Bookmark)

struct HeaderView: View {
    @Environment(\.dismiss) var dismiss
    var area: SmokingArea
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss() // Custom back action
            }) {
                
                Text("Close")
                    .font(.subheadline)
                
                    .foregroundColor(.green.mix(with: .black, by: 0.3))
                    .padding()
                    .frame(width: 85, height: 30)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
                
            }
            Spacer()
            
            Button(action: {
                area.isFavorite.toggle()
                do {
                    try context.save()
                } catch {
                    print("Failed to save: \(error)")
                }
            }) {
                Image(systemName: area.isFavorite ? "bookmark.fill" : "bookmark")
                    .resizable()
                    .frame(width: 20, height: 28)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 50)
    }
}

struct LocationInfoView: View {
    var name: String
    var location: String
    
    var body: some View {
        HStack {
            Text(name)
                .bold()
                .font(.title3)
            BadgeView(text: location, color: .darkGreen)
        }.padding(.bottom, -5)
    }
}


struct CigaretteTypeView: View {
    var types: [String]
    var body: some View {
        SectionView(title: "Cigarette Type") {
            HStack {
                ForEach(types, id: \.self) { type in
                    BadgeView(text: type, color: .orangetheme.opacity(1))
                }
            }
            .frame(width: 340, alignment: .leading)
            .background(Color.orangetheme.opacity(0.4))
            .cornerRadius(10)
            
        }
    }
}


struct FacilitiesView: View {
    var facilities: [Facility]
    
    var body: some View {
        SectionView(title: "Facilities") {
            HStack {
                ForEach(facilities, id: \.name) { facility in
                    BadgeView(text: facility.name, color: .darkGreen.opacity(1))
                }
            }
            .frame(width: 340, alignment: .leading)
            .background(Color.darkGreen.opacity(0.4))
            .cornerRadius(10)
        }
        .padding(5)
    }
}


struct PreferenceGaugeView: View {
    var area: SmokingArea
    var userModel: UserModel
    
    var matchPercentage: Double {
        calculateMatchPercentage(for: area, user: userModel)
    }
    
    var matchedPreferences: [PreferenceMatch] {
        var matches: [PreferenceMatch] = []
        
        // Ambience
        if area.ambience.caseInsensitiveCompare(userModel.ambiencePreference) == .orderedSame {
            matches.append(PreferenceMatch(icon: "sun.max", label: userModel.ambiencePreference))
        }
        
        // Crowd
        if area.crowdLevel.caseInsensitiveCompare(userModel.crowdLevelPreference) == .orderedSame {
            matches.append(PreferenceMatch(icon: "moon.zzz", label: userModel.crowdLevelPreference))
        }
        
        // Facilities
        let userFacilities = Set(userModel.facilityPreference.map { $0.lowercased() })
        let areaFacilities = Set(area.facilities.map { $0.name.lowercased() })
        let matchedFacilities = userFacilities.intersection(areaFacilities)
        
        for type in matchedFacilities {
            matches.append(PreferenceMatch(icon: icon(for: type), label: type.capitalized))
            
            
        }
        
        // Smoking Type
        let userTypes = Set(userModel.type.map { $0.lowercased() })
        let areaTypes = Set(area.smokingTypes.map { $0.lowercased() })
        let matchedTypes = userTypes.intersection(areaTypes)
        
        for type in matchedTypes {
            matches.append(PreferenceMatch(icon: icon(for: type), label: type.capitalized))
        }
        
        
        return matches
    }
    
    struct PreferenceMatch: Identifiable {
        let id = UUID()
        let icon: String
        let label: String
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Gauge(value: matchPercentage, in: 0...100) {
                } currentValueLabel: {
                    Text("\(Int(matchPercentage))%")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.red.opacity(0.8))
                }
                .gaugeStyle(.accessoryCircular)
                .tint(Color.orange.opacity(0.5))
                
                Text("Match Your Preference")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack {
                    ForEach(matchedPreferences) { pref in
                        PreferenceIconView(icon: pref.icon, label: pref.label)
                    }
                }
            }
            
            
        }
        .frame(width: 340, alignment: .leading)
        
        
    }
    
    func icon(for label: String) -> String {
        switch label.lowercased() {
        case "bright": return "sun.max"
        case "dim": return "cloud"
        case "quiet", "silent": return "zzz"
        case "crowded": return "person.3"
        case "chair": return "chair.lounge"
        case "waste bin": return "trash"
        case "roof": return "house" // placeholder
        case "cigarette": return "flame"
        case "e-cigarette": return "flame.fill"
        default: return "questionmark.circle"
        }
    }
    
    private func calculateMatchPercentage(for area: SmokingArea, user: UserModel) -> Double {
        var score = 0.0
        var total = 0.0
        
        // Ambience (1 point)
        total += 1
        if area.ambience.caseInsensitiveCompare(user.ambiencePreference) == .orderedSame {
            score += 1
            print("✅ Ambience matched")
        } else {
            print("❌ Ambience mismatch: \(area.ambience) vs \(user.ambiencePreference)")
        }
        
        total += 1
        if area.crowdLevel.caseInsensitiveCompare(user.crowdLevelPreference) == .orderedSame {
            score += 1
        } else {
        }
        
        
        let userFacilities = Set(user.facilityPreference.map { $0.lowercased() })
        let areaFacilities = Set(area.facilities.map { $0.name.lowercased() })
        
        let matchingFacilities = userFacilities.intersection(areaFacilities).count
        print("🔍 Facilities match count: \(matchingFacilities)/\(userFacilities.count)")
        
        score += Double(matchingFacilities)
        total += Double(userFacilities.count)
        
        // Smoking Types
        let userTypes = Set(user.type.map { $0.lowercased() })
        let areaTypes = Set(area.smokingTypes.map { $0.lowercased() })
        
        let matchingTypes = userTypes.intersection(areaTypes).count
        print("🔍 Smoking type match count: \(matchingTypes)/\(userTypes.count)")
        
        score += Double(matchingTypes)
        total += Double(userTypes.count)
        
        let final = total > 0 ? (score / total) * 100.0 : 0.0
        print("➡️ Final Score: \(final)%")
        return final
    }
    
    
    
}


// MARK: - Waste Bin Direction
struct WasteBinDirectionView: View {
    var photoURL: String
    var directions: String
    
    var body: some View {
        VStack {
            Text("Waste Bin")
                .font(.body)
                .bold()
                .padding(.top, 10)
                .frame(width: 340, alignment: .leading)
                .foregroundStyle(Color.black)
            HStack {
                
                if UIImage(named: photoURL) != nil {
                    Image(photoURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .cornerRadius(10)
                        .padding(.trailing,5)
                        .padding(.top, 0)
                } else {
                    Text("Image not found: \(photoURL)")
                        .foregroundColor(.red)
                }
                
                ScrollView(.vertical, showsIndicators: false){
                    VStack(alignment: .leading) {
                        Text("Directions")
                            .font(.callout)
                            .bold()
                            .padding(.bottom, 1)
                            .padding(.top, 5)
                        Text(directions)
                            .font(.caption2)
                            .padding(.trailing, 20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                
            }
            .frame(width: 356, height: 159)
            //            .background(Color.green.opacity(0.15))
            //            .cornerRadius(10)
        }
        .padding(10)
    }
}


struct BadgeView: View {
    var text: String
    var color: Color
    
    var body: some View {
        VStack{
            Text(text)
                .font(.caption)
                .padding(5)
                .bold()
                .foregroundColor(.white)
                .background(color)
                .cornerRadius(10)
        }
        .padding(5)
        
    }
}

struct SectionView<Content: View>: View {
    var title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.body)
                .bold()
            content
        }
        .padding(5)
    }
}

struct PreferenceIconView: View {
    var icon: String
    var label: String
    
    var body: some View {
        VStack {
            
            
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.orange)
            
            Text(label)
                .font(.caption)
        }
        .padding(.trailing, 10)
    }
}

struct CarouselView: View {
    let images: [String]
    
    var body: some View {
        TabView {
            ForEach(images, id: \.self) { image in
                if let uiImage = UIImage(named: image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: .infinity, height: 200)
                        .clipped()
                        .cornerRadius(10)
                        .padding()
                } else if let url = URL(string: image),
                          let data = try? Data(contentsOf: url),
                          let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 200)
                        .clipped()
                        .cornerRadius(10)
                        .padding()
                } else {
                    Text("Image not found: \(image)")
                        .foregroundColor(.red)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 220)
    }
}



#Preview {
    DetailView(area: SmokingArea(
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
    ))
}
