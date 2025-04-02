import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var allSmokingAreas: [SmokingArea]
    
    // MARK: - UI States
    @State private var showModal = false
    @State private var detent: PresentationDetent = .fraction(0.06)
    @State private var isExpanded = false
    @State private var showSmokingAlert = false
    @State private var hasShownAlert = false
    
    @Namespace private var popUpNameSpace
    
    // MARK: - Selection & Location
    @State private var selectedArea: SmokingArea?
    @State private var userLocation: CLLocation?
    
    // MARK: - Filter Selection
    @State private var selectedFilter: BottomModalView.FilterType = .nearest
    
    private let gradeOrder: [String: Int] = [
        "High": 0, "Moderate": 1, "Low": 2
    ]
    
    // MARK: - Computed Filtered Data
    private var nearestAreas: [SmokingArea] {
        guard let userLocation else { return allSmokingAreas }
        return allSmokingAreas.sorted {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                .distance(from: userLocation) <
            CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                .distance(from: userLocation)
        }
    }
    
    private var facilityFilteredAreas: [SmokingArea] {
        allSmokingAreas.sorted {
            (gradeOrder[$0.facilityGrade] ?? 3) < (gradeOrder[$1.facilityGrade] ?? 3)
        }
    }
    
    private var displayAreas: [SmokingArea] {
        switch selectedFilter {
        case .nearest: return nearestAreas
        case .facility: return facilityFilteredAreas
        case .favorite: return allSmokingAreas.filter { $0.isFavorite }
        }
    }
    
    private var pinColor: UIColor? {
        switch selectedFilter {
        case .nearest: return .orangetheme
        case .facility: return nil
        case .favorite: return .systemYellow
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {

                    MapView(
                        context: modelContext,
                        showModal: $showModal,
                        selectedArea: $selectedArea,
                        filteredAreas: displayAreas,
                        colorOverride: pinColor
                    )
                    .edgesIgnoringSafeArea(.all)

                
                if showSmokingAlert {
                    alertOverlay
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !showSmokingAlert {
                        Button(action: {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                showSmokingAlert = true
                            }
                        }) {
                            Image(systemName: "exclamationmark.triangle")
                                .matchedGeometryEffect(id: "smokingPopup", in: popUpNameSpace)
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Color.darkGreen)
                                .clipShape(Circle())
                        }
                    }

                    Button(action: {
                        print("button preference")
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                            .padding(7)
                            .background(Color.darkGreen)
                            .clipShape(Circle())
                    }

                    Image("NoSmokingLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                }
            }

            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear(perform: onAppearTasks)
            .sheet(isPresented: $showModal) {
                BottomModalView(
                    isExpanded: $isExpanded,
                    detent: $detent,
                    selectedArea: $selectedArea,
                    selectedFilter: $selectedFilter
                )
                .presentationDetents([.fraction(0.06), .fraction(0.65)], selection: $detent)
                .onChange(of: detent) { _, newDetent in
                    withAnimation {
                        isExpanded = newDetent == .fraction(0.65)
                    }
                }
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled(true)
            }
        }
    }
    
    // MARK: - Alert Overlay
    private var alertOverlay: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation {
                    showSmokingAlert = false
                }
            }
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "lungs.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.red)
                    
                    Text("Smoking increases the risk of cancer, heart disease, and lung problems. Your health matters more than a habit.")
                        .font(.body)
                        .frame(width: 250)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
                .matchedGeometryEffect(id: "smokingPopup", in: popUpNameSpace)
                .transition(.opacity)
            )
    }
    
    // MARK: - Lifecycle Logic
    private func onAppearTasks() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showModal = true
        }
        
        LocationManager.shared.getUserLocation { location in
            self.userLocation = location
        }
        
        if !hasShownAlert {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showSmokingAlert = true
                    hasShownAlert = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
