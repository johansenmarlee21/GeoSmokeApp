import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showModal = false
    @State private var detent: PresentationDetent = .fraction(0.06)
    @State private var isExpanded: Bool = false
    
  
    var body: some View {
        NavigationStack {
            ZStack {
                MapView(context:  modelContext)
                    .edgesIgnoringSafeArea(.all)
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
                    Button(action: {
                        print("hehehe")
                    }) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.white)
                            .padding(7)
                            .background(Color.darkGreen)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        print("sldhfds")
                    }) {
                        Image(systemName: "smoke.fill")
                            .foregroundColor(.darkGreen)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                DispatchQueue.main.async {
                    SmokingAreaSeeder.seedData(context: modelContext)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showModal = true
                }
            }
            .sheet(isPresented: $showModal) {
                BottomModalView(isExpanded: $isExpanded, detent: $detent)
                    .presentationDetents([.fraction(0.06), .fraction(0.65)], selection: $detent)
                    .onChange(of: detent) { newDetent in
                        withAnimation {
                            isExpanded = newDetent == .fraction(0.65)
                        }
                    }
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(true)
            }
        }
    }
}

#Preview {
    ContentView()
}
