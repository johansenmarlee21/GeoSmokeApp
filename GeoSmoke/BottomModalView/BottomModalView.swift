import SwiftUI

struct BottomModalView: View {
    
    @Binding var isExpanded: Bool
    @Binding var detent: PresentationDetent
    @Binding var selectedArea: SmokingArea?
    @Binding var selectedFilter: FilterType
    
    
    enum FilterType: String {
        case nearest = "Nearest"
        case favorite = "Favorite"
        case facility = "Facility"
    }
    
    var body: some View {
        VStack(alignment: .leading){
            
            HStack{
                
                Text(selectedFilter == .facility ? "Facility Grade" : selectedFilter.rawValue)
                    .font(.title)
                    .bold()
                    .padding(.top, 23)
                    .padding(.horizontal)
                
                
                Spacer()
                if(isExpanded == false){
                    Button(action: {
                        withAnimation{
                            isExpanded = true
                            detent = .fraction(0.65)
                        }
                    }){
                        Image(systemName: "ellipsis")
                            .foregroundColor(.orange)
                    }
                }
                else{
                    Button(action: {
                        withAnimation{
                            isExpanded = false
                            detent = .fraction(0.06)
                        }
                        NotificationCenter.default.post(name: .returnToUserLocation, object: nil)
                    }){
                        Text("Close")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                    }
                }
                
            }
            
            
            
            if isExpanded {
                HStack{
                    FilterButton(title: "Nearest", type: .nearest, icon: "location", width: 30, height: 30, selectedFilter: $selectedFilter)
                        .padding(.trailing, 15)
                    FilterButton(title: "Facility", type: .facility, icon: "chair", width: 18, height: 28, selectedFilter: $selectedFilter)
                        .padding(.trailing, 15)
                    FilterButton(title: "Favorite", type: .favorite, icon: "bookmark", width: 18, height: 25, selectedFilter: $selectedFilter)
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green100)
                .cornerRadius(20)
                
                switch selectedFilter {
                case .nearest:
                    NearestView(onSelect: { area in
                        selectedArea = area
                    })
                case .favorite:
                    FavoriteView(onSelect: { area in
                        selectedArea = area
                    })
                case .facility:
                    FacilityView(onSelect: { area in
                        selectedArea = area
                    })
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
                Image(systemName: selectedFilter == type ? "\(icon).fill" : icon)
                    .resizable()
                    .frame(width: width, height: height)
                    .padding(13)
                    .frame(width: 54, height: 54)
                    .foregroundColor(selectedFilter == type ? Color.darkGreen : Color.black.opacity(0.9))
                //                    .foregroundColor(.black.opacity(0.9))
                    .background(selectedFilter == type ? Color.green300 : Color.white)
                    .clipShape(.circle)
                
            }
            Text(title)
                .font(.system(size: 13))
            
        }
    }
}

extension Notification.Name{
    static let returnToUserLocation = Notification.Name("returnToUserLocation")
}



#Preview {
    struct PreviewWrapper: View {
        @State var isExpanded = true
        @State var detent: PresentationDetent = .fraction(0.06)
        @State var selectedArea: SmokingArea?
        @State var selectedFilter: BottomModalView.FilterType = .facility
        
        var body: some View {
            BottomModalView(
                isExpanded: $isExpanded,
                detent: $detent,
                selectedArea: $selectedArea,
                selectedFilter: $selectedFilter
            )
        }
    }
    
    return PreviewWrapper()
}
