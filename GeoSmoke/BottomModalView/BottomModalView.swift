import SwiftUI

struct BottomModalView: View {
    @State private var selectedFilter: FilterType = .nearest
    @Binding var isExpanded: Bool
    @Binding var detent: PresentationDetent
    
    
    
    enum FilterType: String {
        case nearest = "Nearest"
        case favorite = "Favorite"
        case facility = "Facility"
    }
    
    var body: some View {
        VStack(alignment: .leading){
            
            HStack{
                Text(selectedFilter.rawValue)
                    .font(.title)
                    .bold()
                    .padding(.top, 23)
                    .padding(.horizontal)
                
                Spacer()
                Button(action: {
                    withAnimation{
                        isExpanded = true
                        detent = .medium
                    }
                }){
                    Image(systemName: "ellipsis")
                        .foregroundColor(.orange)
                }
            }
            
            
            
            if isExpanded {
                HStack{
                    FilterButton(title: "Nearest", type: .nearest, icon: "location.fill", width: 30, height: 30, selectedFilter: $selectedFilter)
                        .padding(.trailing, 15)
                    
                    FilterButton(title: "Facility", type: .facility, icon: "chair", width: 22, height: 32, selectedFilter: $selectedFilter)
                        .padding(.trailing, 15)
                    FilterButton(title: "Favorite", type: .favorite, icon: "bookmark", width: 25, height: 30, selectedFilter: $selectedFilter)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green100)
                .cornerRadius(20)
                
                switch selectedFilter {
                case .nearest:
                    NearestView()
                case .favorite:
                    FavoriteView()
                case .facility:
                    FacilityView()
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
        
}


struct FilterButton:View {
    let title: String
    let type: BottomModalView.FilterType
    let icon: String
    let width: CGFloat
    let height: CGFloat
    @Binding var selectedFilter: BottomModalView.FilterType
    
    var body: some View{
        
        VStack {
            Button(action: {
                selectedFilter = type
            }) {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: width, height: height)
                    .padding(13)
                    .foregroundColor(.black.opacity(0.9))
                    .background(selectedFilter == type ? Color.green300 : Color.white)
                    .clipShape(.circle)
                
            }
            
            Text(title)
                .font(.system(size: 13))
                
        }
    }
}





#Preview {
    struct PreviewWrapper: View {
        @State var isExpanded = true
        @State var detent: PresentationDetent = .fraction(0.06)
        
        var body: some View {
            BottomModalView(isExpanded: $isExpanded, detent: $detent)
        }
    }
    
    return PreviewWrapper()
}
