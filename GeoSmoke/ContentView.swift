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
    @State private var smokingAreas: [SmokingArea] = []
    @State private var userLocation: CLLocation?
    @State private var isInSmokingArea: Bool = false
    @State var isPresented: Bool = false
    @State var selectedAmbience: String
    @State var selectedCrowd: String
    @State var selectedFacilities: Set<String>
    @State var selectedTypes: Set<String>
    @State private var currentUser: UserModel?
    @State private var showSaveConfirmation = false
    
    @StateObject private var locationManager = LocationManager.shared
    
    @Namespace private var popUpNameSpace
    @Namespace private var popUpPreferences
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    
    
    // MARK: - Selection & Location
    @State private var selectedArea: SmokingArea?
    
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
                if isPresented {
                    Color.black.opacity(0.6) // Background dimming
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    
                    PreferencesView(
                        isPresented: $isPresented,
                        selectedAmbience: $selectedAmbience,
                        selectedCrowd: $selectedCrowd,
                        selectedFacilities: $selectedFacilities,
                        selectedTypes: $selectedTypes,
                        onSave: saveUserPreferences
                    )
                    .transition(.scale.combined(with: .opacity))
                    .matchedGeometryEffect(id: "PreferencesPopUp", in: popUpPreferences)
                    .zIndex(4)
                }
                if showSmokingAlert{
                    //                    alertOverlay
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .onTapGesture{
                            withAnimation{
                                showSmokingAlert = false
                            }
                        }
                    
                    VStack(spacing: 16){
                        Image("LogoWarning")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color.red)
                            .padding(.top, 20)
                        Text("Smoking increase the risk of cancer, heart disease, and lung problems. Your health matters more than a habit.")
                            .font(.body)
                            .frame(width: 200)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                    .matchedGeometryEffect(id: "smokingPopup", in: popUpNameSpace)
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)
                    .zIndex(3)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading){
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                    
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)){
                            showSmokingAlert = true
                        }
                    }) {
                        Image(systemName: "exclamationmark.triangle")
                            .matchedGeometryEffect(id: "smokingPopup", in: popUpNameSpace)
                            .foregroundColor(.white)
                            .scaledToFit()
                            .padding(7)
                            .frame(width: 36)
                            .background(Color.orangetheme)
                            .clipShape(Circle())
                        
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)){
                            isPresented = true
                        }
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .matchedGeometryEffect(id: "PreferencesPopUp", in: popUpPreferences)
                            .foregroundColor(.white)
                            .scaledToFit()
                            .padding(7)
                            .frame(width: 37)
                            .background(Color.darkGreen)
                            .clipShape(Circle())
                    }
                    
                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    Image(isInSmokingArea ? "SmokingLogo" : "NoSmokingLogo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 55)
//                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showModal = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    withAnimation{
                        showSmokingAlert = true
                    }
                }
                Task{
                    do{
                        let descriptor = FetchDescriptor<SmokingArea>()
                        smokingAreas = try modelContext.fetch(descriptor)
                        
                        LocationManager.shared.getUserLocation {location in
                            if let location = location{
                                self.userLocation = location
                                checkIfUserIsInSmokingArea(location)
                            }
                        }
                    }catch {
                        print("❌ Failed to fetch smoking areas: \(error)")
                    }
                    
                    let descriptor = FetchDescriptor<UserModel>()
                    do {
                        let existingUsers = try modelContext.fetch(descriptor)
                        
                        if let user = existingUsers.first {
                            currentUser = user
                            selectedAmbience = user.ambiencePreference
                            selectedCrowd = user.crowdLevelPreference
                            selectedFacilities = Set(user.facilityPreference)
                            selectedTypes = Set(user.type)
                            print("✅ Loaded existing user preferences into state")
                        } else {
                            let defaultUser = UserModel(
                                ambiencePreference: selectedAmbience,
                                crowdLevelPreference: selectedCrowd,
                                facilityPreference: Array(selectedFacilities),
                                type: Array(selectedTypes)
                            )
                            modelContext.insert(defaultUser)
                            try modelContext.save()
                            currentUser = defaultUser
                            print("✅ Default user saved at first launch")
                        }
                    } catch {
                        print("❌ Error checking user model: \(error)")
                    }
                }
                
                if !hasLaunchedBefore {
                    withAnimation {
                        isPresented = true
                    }
                    hasLaunchedBefore = true
                }
                
                
            }
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
            .alert("Preferences Saved", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) { }
            }
            .onChange(of: showSaveConfirmation) { newValue in
                if newValue == false {
                    // Alert just dismissed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showModal = true
                    }
                }
            }
            
        }
    }
    
    // MARK: - Alert Overlay
    var alertOverlay: some View {
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
    //        func onAppearTasks() {
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    //                showModal = true
    //            }
    //
    //            LocationManager.shared.getUserLocation { location in
    //                self.userLocation = location
    //            }
    //
    //            if !hasShownAlert {
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    //                    withAnimation {
    //                        showSmokingAlert = true
    //                        hasShownAlert = true
    //                    }
    //
    //                }
    //            }
    //        }
    
    func checkIfUserIsInSmokingArea(_ userLocation:CLLocation){
        let allowedDistance: Double = 10.00
        
        isInSmokingArea = smokingAreas.contains {area in
            let areaLocation = CLLocation(latitude: area.latitude, longitude: area.longitude)
            return userLocation.distance(from: areaLocation) <= allowedDistance
        }
    }
    func saveUserPreferences() {
        let descriptor = FetchDescriptor<UserModel>()
        
        do {
            let existingUsers = try modelContext.fetch(descriptor)
            
            for user in existingUsers {
                modelContext.delete(user)
            }
            
            let user = UserModel(
                ambiencePreference: selectedAmbience,
                crowdLevelPreference: selectedCrowd,
                facilityPreference: Array(selectedFacilities),
                type: Array(selectedTypes)
            )
            modelContext.insert(user)
            
            try modelContext.save()
            print("✅ Preferences saved and old ones replaced.")
            
            showSaveConfirmation = true
            
        } catch {
            print("❌ Failed to save preferences: \(error)")
        }
    }
    
    
}


#Preview {
    ContentView(
        selectedAmbience: "dark",
        selectedCrowd: "low",
        selectedFacilities: ["Chair"],
        selectedTypes: ["E-cigarette"]
    )
}


