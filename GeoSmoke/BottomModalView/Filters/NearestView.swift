import SwiftUI
import SwiftData
import CoreLocation


struct NearestView: View {
    @Query var smokingAreas: [SmokingArea]
    @StateObject private var locationManager = LocationManager.shared
    @State private var userLocation: CLLocation?
    @State private var distances: [PersistentIdentifier: Double] = [:]
    @State private var selectedArea: SmokingArea? = nil
    
    var onSelect: ((SmokingArea) -> Void)? = nil
    
    // MARK: - Computed properties
    private var sortedAreas: [SmokingArea] {
        smokingAreas.sorted(by: sortByDistance)
    }
    
    private var nearestArea: SmokingArea? {
        sortedAreas.first
    }
    
    private var otherAreas: [SmokingArea] {
        Array(sortedAreas.dropFirst())
    }
    
    // MARK: - View
    var body: some View {
        VStack(alignment: .center) {
            if smokingAreas.isEmpty {
                Text("No Smoking Areas Available")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        if let nearest = nearestArea {
                            VStack {
                                NearestCardView(
                                    area: nearest,
                                    distance: distances[nearest.id],
                                    onSelect: onSelect
                                )
                                .padding(.bottom, 5)
                                Divider()
                            }
                        }
                        
                        ForEach(otherAreas, id: \.id) { area in
                            let isSelected = selectedArea?.id == area.id
                            SmokingAreaListItem(
                                area: area,
                                distance: distances[area.id],
                                isSelected: isSelected,
                                onSelect: { selected in
                                    selectedArea = selected
                                    onSelect?(selected)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 0)
                }
            }
        }
        .onAppear {
            locationManager.getUserLocation { location in
                if let location = location {
                    self.userLocation = location
                    calculateAllDistances(from: location)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func calculateAllDistances(from location: CLLocation) {
        var newDistances: [PersistentIdentifier: Double] = [:]
        for area in smokingAreas {
            let areaLocation = CLLocation(latitude: area.latitude, longitude: area.longitude)
            newDistances[area.persistentModelID] = location.distance(from: areaLocation)
        }
        distances = newDistances
    }
    
    private func sortByDistance(_ a: SmokingArea, _ b: SmokingArea) -> Bool {
        let d1 = distances[a.persistentModelID] ?? .greatestFiniteMagnitude
        let d2 = distances[b.persistentModelID] ?? .greatestFiniteMagnitude
        return d1 < d2
    }
}




struct NearestCardView: View{
    var area: SmokingArea
    var distance: Double?
    var onSelect: ((SmokingArea) -> Void)? = nil
    @State private var showDetail = false

    
    var body: some View{
        VStack(alignment: .center, spacing: 0){
            VStack{
                if UIImage(named: area.photoURL) != nil {
                    Image(area.photoURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: .infinity, height: 140)
                        .clipped()
                        .cornerRadius(5)
                        .clipped()
                        .cornerRadius(10)
                    //                        .padding(.top, 10)
                    //                        .padding(.horizontal, 12)
                    //                        .padding(.bottom, 5)
                } else {
                    Text("Image not found: \(area.photoURL)")
                        .foregroundColor(.red)
                }

                
                HStack(alignment: .center){
                    Text(area.name)
                        .font(.system(size:17))
                        .fontWeight(.semibold)
                        .padding(.trailing, 20)
                        .padding(.leading, 12)
                    //                    Text(area.location)
                    //                        .font(.subheadline)
                    //                        .padding(.leading, 1)
                    Spacer()
                    
                    Button(action: {
                        showDetail = true
                    }){
                        HStack{
                            Text("Detail")
                                .font(.subheadline)
                                .foregroundColor(Color.darkGreen)
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(Color.darkGreen)
                        }
                        .padding(.trailing, 12)
                        
                    }
                    .fullScreenCover(isPresented: $showDetail) {
                        DetailView(area: area)
                    }

                }
            }
            .frame(width: 300)
            .padding(.bottom, 5)
            .background(Color.green100)
            .cornerRadius(15)
            
            
            HStack{
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width:21)
                    .foregroundColor(Color.orangetheme)
                Text(distanceText)
                    .foregroundColor(Color.orangetheme)
                    .fontWeight(.bold)
                    .font(.system(size: 20))
            }
            .padding(.top, 10)
        }
        .onAppear {
            onSelect?(area)
            print("area.name: \(area.name)")
            print("area.photoURL: \(area.photoURL)")
            
        }
    }
    private var distanceText: String {
        if let d = distance{
            return String(format: "%.0f meters", d)
        }else{
            return "Loading..."
        }
    }
}



struct SmokingAreaListItem: View {

    var area: SmokingArea
    var distance: Double?
    var isSelected: Bool
    var onSelect: ((SmokingArea) -> Void)? = nil
    
    @State private var showDetail = false

    
    var body: some View {
        HStack(alignment: .center){
            if UIImage(named: area.photoURL) != nil {
                Image(area.photoURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 115, height: 70)
                    .cornerRadius(5)
                    .padding(.leading, 5)
            } else {
                Text("Image not found: \(area.photoURL)")
                    .foregroundColor(.red)
            }
            
            
            VStack(alignment: .leading, spacing: 0) {
                Text(area.name)

                    .font(.system(size:15))
                    .fontWeight(.semibold)
                Text(area.location)
                    .font(.system(size: 12))

                    .padding(.vertical, 1)
                    .padding(.horizontal, 8)
                    .background(Color.green300)
                    .cornerRadius(8)
                    .padding(.top, 2)
                Spacer()
                if let distance = distance{
                    Text("\(Int(distance)) meters")
                        .font(.headline)
                        .foregroundColor(isSelected ? Color.orangetheme: Color.black)
                        .fontWeight(isSelected ? .bold : .regular)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
            }
            
            Spacer()
            
            Button(action: {
                showDetail = true

            }){
                VStack(alignment: .center){
                    Image(systemName: "location.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.white)
                    
                    Text("Detail")
                        .font(.subheadline)
                        .foregroundColor(Color.white)
                }
                .frame(width: 60)
                .frame(maxHeight: 70)
                .background(Color.orangetheme)
                .cornerRadius(10)
                .padding(.trailing, 5)

            }
            .fullScreenCover(isPresented: $showDetail) {
                DetailView(area: area)
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            DetailView(area: area)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .frame(height: 85)
        .background(Color.green100)
        .cornerRadius(10)
        .onTapGesture {
            onSelect?(area)
        }
        .shadow(color: .splashGreen.opacity(isSelected ? 0.7 : 0),
                radius: isSelected ? 5 : 0)
    }
}

#Preview {
    NearestCardView(area: SmokingArea(
        name: "Garden Seating",
        location: "GOP 1",
        latitude: -6.3009886,
        longitude: 106.6510372,
        photoURL: "TheJog1",
        disposalPhotoURL: "https://picsum.photos/200/300",
        disposalDirection: "Near the entrance",
        facilities: [],
        isFavorite: false,
        allPhoto: [],
        facilityGrade: "Moderate",
        ambience: "Quiet",
        crowdLevel: "Low",
        smokingTypes: ["Open Area"]
    ))
}

