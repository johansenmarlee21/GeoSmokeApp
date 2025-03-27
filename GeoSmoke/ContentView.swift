import SwiftUI

struct ContentView: View {
    
    @State private var showModal = false
    @State private var detent: PresentationDetent = .fraction(0.06)
    @State private var isExpanded: Bool = false
  
    var body: some View{
        ZStack{
            TopView()
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showModal = true
            }
        }
        .sheet(isPresented: $showModal){
            BottomModalView(isExpanded: $isExpanded, detent: $detent)
                .presentationDetents([.fraction(0.06), .medium], selection: $detent).onChange(of: detent){ newDetent in
                    withAnimation{
                        isExpanded = newDetent == .medium
                    }
                        
                    
                }
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
        }
        
    }
    
    }

#Preview {
    ContentView()
}
