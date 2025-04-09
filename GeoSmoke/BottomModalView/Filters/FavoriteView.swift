import SwiftUI
import SwiftData

struct FavoriteView: View{
    @Query(filter: #Predicate<SmokingArea> { $0.isFavorite == true })
    
    var favoriteAreas: [SmokingArea] = []
    
    @State private var selectedArea: SmokingArea? = nil
    
    var onSelect: (SmokingArea) -> Void
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if favoriteAreas.isEmpty {
                EmptyFavoriteView()
            } else {
                ScrollView{
                    LazyVStack{
                        ForEach(favoriteAreas) { area in
                            let isSelected = selectedArea?.id == area.id
                            FavoriteListItem(
                                area: area,
                                isSelected: isSelected,
                                onSelect: { selected in
                                    selectedArea = selected
                                    onSelect(selected)
                                }
                            )
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}

struct EmptyFavoriteView: View {
    var body: some View {
        Spacer()
        VStack(alignment: .center){
            Image(systemName: "bookmark.fill")
                .resizable()
                .frame(maxWidth: 40, maxHeight: 56)
                .foregroundStyle(Color.orange)
            
            Text("You have no favorite locations at this moment")
                .font(.headline)
                .frame(maxWidth: 241, maxHeight: 50)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            Text("Save Your Favorite Locations in the location detail page")
                .font(.footnote)
                .frame(maxWidth: 180)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth:.infinity)
        .padding(.top, 10)
    }
}

struct FavoriteListItem: View {
    var area: SmokingArea
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
                    .font(.headline)
                Text(area.location)
                    .font(.system(size: 13))
                    .padding(.vertical, 1)
                    .padding(.horizontal, 8)
                    .background(Color.green300)
                    .cornerRadius(8)
                    .padding(.top, 2)
                Spacer()
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(area.facilities, id: \.name) { facility in
                            Image(systemName: iconName(for: facility.name))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .padding(.trailing, 3)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack{
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
    
    func iconName(for facility: String) -> String {
        switch facility {
        case "Chair":
            return "chair.lounge"
        case "Waste Bin":
            return "trash"
        case "Roof":
            return "house"
        default:
            return "questionmark.circle" // fallback icon
        }
    }
}

//#Preview {
//    FavoriteListItem(area: SmokingArea(
//        name: "Garden Seating",
//        location: "Garden",
//        latitude: -6.3013122,
//        longitude: 106.6522975,
//        photoURL: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
//        disposalPhotoURL: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
//        disposalDirection: "disitu",
//        facilities: [
//            Facility(name: "Chair"),
//            Facility(name: "Waste Bin"),
//        ],
//        isFavorite: false,
//        allPhoto: [
//            LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
//            LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
//            LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
//            LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png")
//        ],
//        facilityGrade: "High"
//    ))
//
//}
