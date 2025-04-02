import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showModal = false
    @State private var detent: PresentationDetent = .fraction(0.06)
    @State private var isExpanded: Bool = false
    @State private var showSmokingAlert = false
    
    @Namespace private var popUpNameSpace
    
  
    var body: some View {
        NavigationStack {
            ZStack {
                MapView(context:  modelContext)
                    .edgesIgnoringSafeArea(.all)
                if showSmokingAlert{
                                    Color.black.opacity(0.7)
                                        .ignoresSafeArea()
                                        .onTapGesture{
                                            withAnimation{
                                                showSmokingAlert = false
                                            }
                                        }
                                    
                                    VStack(spacing: 16){
                                        Image(systemName: "lungs.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(Color.red)
                                        Text("Smoking increase the risk of cancer, heart disease, and lung problems. Your health matters more than a habit.")
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
                                    .frame(maxHeight: .infinity)
                                    .transition(.opacity)
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
                                        if !showSmokingAlert {
                                            Image(systemName: "exclamationmark.triangle")
                                                .matchedGeometryEffect(id: "smokingPopup", in: popUpNameSpace)
                                                .foregroundColor(.white)
                                                .padding(7)
                                                .background(Color.darkGreen)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        print("button preference")
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                            .padding(7)
                            .background(Color.darkGreen)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image("NoSmokingLogo")
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
}

#Preview {
    ContentView()
}
