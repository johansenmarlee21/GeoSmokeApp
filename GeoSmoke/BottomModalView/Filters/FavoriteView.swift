import SwiftUI
import SwiftData

struct FavoriteView: View{
    @Query(filter: #Predicate<SmokingArea> { $0.isFavorite == true })

    var favoriteAreas: [SmokingArea] = []
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Pastikan latar belakang putih di seluruh layar
                
            if favoriteAreas.isEmpty {
                EmptyFavoriteView()
            } else {
                List(favoriteAreas) { area in
                    VStack(alignment: .leading) {
                        FavoriteListItem(area: area)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden) // Hilangkan default background List
                .background(Color.white) // Tetapkan background putih
                .listStyle(PlainListStyle()) // Gunakan gaya List yang bersih
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
                Text("90% Match Your Preference")
                    .font(.caption2)
            }
            
            Spacer()
            
            VStack{
                Image(systemName: "bookmark.fill")
                    .resizable()
                    .frame(width: 20, height: 28)
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
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
//        isFavorite: true
//    ))
    
    FavoriteView()
}
