import SwiftUI
import SwiftData
import CoreLocation


struct NearestView: View{
    @Query var smokingAreas: [SmokingArea]
    @State private var userLocation: CLLocation?
    
    var sortedSmokingAreas: [SmokingArea] {
            guard let userLocation = userLocation else { return smokingAreas }
            
            return smokingAreas.sorted {
                let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                return loc1.distance(from: userLocation) < loc2.distance(from: userLocation)
            }
        }

        var body: some View {
            VStack(alignment: .center) {
                if sortedSmokingAreas.isEmpty {
                    Text("No Smoking Areas Available")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(sortedSmokingAreas.indices, id: \.self) { index in
                                let area = sortedSmokingAreas[index]
                                
                                if index == 0 {
                                    VStack {
                                        NearestCardView(area: area)
                                            .padding(.bottom, 5)
                                        Divider()
                                    }
                                } else {
                                    SmokingAreaListItem(area: area)
                                }
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                }
            }
            .onAppear {
                fetchUserLocation()
            }
        }
    private func fetchUserLocation() {
            LocationManager.shared.getUserLocation { location in
                self.userLocation = location
            }
        }
}



struct NearestCardView: View{
    var area: SmokingArea
    @State private var showDetail = false

    
    var body: some View{
        VStack(alignment: .center, spacing: 0){
            AsyncImage(url: URL(string: area.photoURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "xmark.circle")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 120)
            .cornerRadius(5)
            .clipped()
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.green100)
            .cornerRadius(10)
            .padding(.bottom, 5)
            
            HStack(alignment: .center){
                Text(area.location)
                    .font(.subheadline)
                    .padding(.trailing, 3)

                    .padding(.horizontal, 8)
                    .background(Color.green300)
                    .cornerRadius(8)
                
                Text(area.name)
                    .font(.system(size:15))
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                
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
                    .fullScreenCover(isPresented: $showDetail) {
                        DetailView(area: area)
                    }

                }
                    
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 18)

            .background(Color.green100)
            .cornerRadius(20)
            
            HStack{
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width:21)
                    .foregroundColor(Color.orangetheme)
                Text("10 Meters")
                    .foregroundColor(Color.orangetheme)
                    .fontWeight(.bold)
                    .font(.system(size: 20))
            }
            .padding(.top, 10)
        }
    }
    
}



struct SmokingAreaListItem: View {

   var area: SmokingArea
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
                Text("25 Meters")
                    .font(.headline)
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
    }
}



#Preview {
    NearestCardView(area: SmokingArea(
        name: "Garden Seating",
        location: "GOP 1",
        latitude: -6.3009886,
        longitude: 106.6510372,
        photoURL: "https://picsum.photos/200/300",
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


