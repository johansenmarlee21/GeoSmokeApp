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
    
    var body: some View{
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(sortedSmokingAreas, id: \.self) { area in
                    FacilityViewItem(area: area)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

struct FacilityViewItem: View {
    let area: SmokingArea
    
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
            
            Spacer()
            
            VStack{
                
                Spacer()
                Button(action: {
                    showDetail = true
                }) {
                    Text("Detail")
                        .font(.caption2)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 4)
                        .frame(width: 40, height: 20)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                    .fullScreenCover(isPresented: $showDetail) {
                        DetailView(area: area)
                    }
            }
            .padding(.trailing, 10)
            
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .frame(height: 85)
        .background(Color.green100)
        .cornerRadius(10)
    }
}

#Preview {
    FacilityViewItem(area: SmokingArea(
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
        facilityGrade: "High"
    ))
}
