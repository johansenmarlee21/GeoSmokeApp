import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showModal = false
    @State private var detent: PresentationDetent = .fraction(0.06)
    @State private var isExpanded: Bool = false
    @State private var showSmokingAlert = false
    @State private var smokingAreas: [SmokingArea] = []
    @State private var userLocation: CLLocation?
    @State private var isInSmokingArea: Bool = false
    @State var isPresented: Bool = false
    @State var selectedAmbience: String
    @State var selectedCrowd: String
    @State var selectedFacilities: Set<String>
    @State var selectedTypes: Set<String>
    @State private var currentUser: UserModel?
    
    @Namespace private var popUpNameSpace
    @Namespace private var popUpPreferences
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapView(context:  modelContext)
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
                    .zIndex(1)
                }
                if showSmokingAlert{
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
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                }
                ToolbarItem(placement: .topBarTrailing) {
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
                                .background(Color.darkGreen)
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
                ToolbarItem(placement: .topBarTrailing) {
                    
                    
                    Image(isInSmokingArea ? "SmokingLogo" : "NoSmokingLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            //            .onAppear {
            //                DispatchQueue.main.async {
            //                    SmokingAreaSeeder.seedData(context: modelContext)
            //                }
            //            }
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
            }
            .sheet(isPresented: $showModal) {
                BottomModalView(isExpanded: $isExpanded, detent: $detent)
                    .presentationDetents([.fraction(0.06), .fraction(0.65)], selection: $detent)
                    .onChange(of: detent) { oldDetent, newDetent in
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

