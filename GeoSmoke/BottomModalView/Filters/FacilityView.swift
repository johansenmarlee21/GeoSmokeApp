import SwiftUI
import SwiftData

struct FacilityView: View{
    
    @Query var smokingAreas: [SmokingArea]
    
    
    private let gradeOrder: [String: Int] = [
        "High": 0,
        "Moderate": 1,
        "Low": 2
    ]
    
    var sortedSmokingAreas: [SmokingArea] {
        smokingAreas.sorted {
            (gradeOrder[$0.facilityGrade] ?? 3) < (gradeOrder[$1.facilityGrade] ?? 3)
        }
    }
    
    var onSelect: ((SmokingArea) -> Void)? = nil

    
    var body: some View{
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(sortedSmokingAreas, id: \.self) { area in
                    FacilityViewItem(area: area, onSelect: onSelect)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

struct FacilityViewItem: View {
    let area: SmokingArea

    var onSelect: ((SmokingArea) -> Void)? = nil
    
    @State private var showDetail = false
    
    var body: some View {
        HStack(alignment: .center){
            AsyncImage(url: URL(string: area.photoURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 115, height: 70)
            .cornerRadius(5)
            .padding(.leading, 5)
            
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
                            Text("\(facility.name)")
                                .font(.system(size: 13))
                                .padding(.vertical, 1)
                                .padding(.horizontal, 8)
                                .background(Color.green.opacity(0.3))
                                .cornerRadius(8)
                                .padding(.top, 2)
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
    }
}

//#Preview {
//    FacilityViewItem(area: SmokingArea(
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
//}

